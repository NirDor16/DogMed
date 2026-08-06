import Foundation

enum Frequency: String {
    case once
    case twice
    case specificDays

    var displayName: String {
        switch self {
        case .once: return "Once a day"
        case .twice: return "Twice a day"
        case .specificDays: return "Specific days of the week"
        }
    }
}

enum MedicationStatus {
    case given
    case pending

    var displayName: String {
        switch self {
        case .given: return "Given"
        case .pending: return "Pending"
        }
    }
}

struct MedicationOccurrence {
    let time: String
    let status: MedicationStatus
}

struct Medication {
    var id: String
    var dogId: String
    var name: String
    var dosage: String
    var frequency: Frequency
    var scheduledTimes: [String]
    var weekdays: [Int]
    var startDate: String
    var endDate: String?
    var notes: String
    var vetName: String?
    var history: [String: [String: Double]]

    init(id: String, dogId: String, name: String, dosage: String, frequency: Frequency,
         scheduledTimes: [String], weekdays: [Int], startDate: String, endDate: String?,
         notes: String, vetName: String?, history: [String: [String: Double]] = [:]) {
        self.id = id
        self.dogId = dogId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.scheduledTimes = scheduledTimes
        self.weekdays = weekdays
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.vetName = vetName
        self.history = history
    }

    init?(id: String, dogId: String, dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let dosage = dict["dosage"] as? String,
              let frequencyRaw = dict["frequency"] as? String,
              let frequency = Frequency(rawValue: frequencyRaw),
              let scheduledTimes = dict["scheduledTimes"] as? [String],
              let startDate = dict["startDate"] as? String else { return nil }

        self.id = id
        self.dogId = dogId
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.scheduledTimes = scheduledTimes
        self.weekdays = (dict["weekdays"] as? [Int]) ?? []
        self.startDate = startDate
        self.endDate = dict["endDate"] as? String
        self.notes = dict["notes"] as? String ?? ""
        self.vetName = dict["vetName"] as? String

        if let rawHistory = dict["history"] as? [String: Any] {
            var parsed: [String: [String: Double]] = [:]
            for (dateKey, value) in rawHistory {
                guard let dayDict = value as? [String: Any] else { continue }
                var day: [String: Double] = [:]
                for (timeKey, timestamp) in dayDict {
                    if let number = timestamp as? NSNumber {
                        day[timeKey] = number.doubleValue
                    }
                }
                parsed[dateKey] = day
            }
            self.history = parsed
        } else {
            self.history = [:]
        }
    }

    /// Excludes "history" — history entries are written/removed via their own path.
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "dosage": dosage,
            "frequency": frequency.rawValue,
            "scheduledTimes": scheduledTimes,
            "weekdays": weekdays,
            "startDate": startDate,
            "notes": notes
        ]
        if let endDate = endDate {
            dict["endDate"] = endDate
        }
        if let vetName = vetName, !vetName.isEmpty {
            dict["vetName"] = vetName
        }
        return dict
    }
}

extension Medication {
    func isActive(on date: Date) -> Bool {
        let day = DateUtils.startOfDay(date)
        guard let start = DateUtils.date(from: startDate) else { return false }
        if day < DateUtils.startOfDay(start) { return false }
        if let endDateString = endDate, let end = DateUtils.date(from: endDateString), day > DateUtils.startOfDay(end) {
            return false
        }
        return true
    }

    func isDue(on date: Date) -> Bool {
        guard isActive(on: date) else { return false }
        switch frequency {
        case .once, .twice:
            return true
        case .specificDays:
            let weekday = Calendar.current.component(.weekday, from: date)
            return weekdays.contains(weekday)
        }
    }

    func occurrences(on date: Date) -> [MedicationOccurrence] {
        guard isDue(on: date) else { return [] }
        let dateKey = DateUtils.key(from: date)
        let dayHistory = history[dateKey] ?? [:]
        return scheduledTimes.sorted().map { time in
            let timeKey = DateUtils.timeKey(from: time)
            let status: MedicationStatus = dayHistory[timeKey] != nil ? .given : .pending
            return MedicationOccurrence(time: time, status: status)
        }
    }

    var weekdaysDisplay: String {
        let symbols = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekdays.sorted().compactMap { $0 >= 1 && $0 <= 7 ? symbols[$0] : nil }.joined(separator: ", ")
    }

    var frequencySummary: String {
        switch frequency {
        case .once, .twice: return frequency.displayName
        case .specificDays: return weekdaysDisplay.isEmpty ? frequency.displayName : weekdaysDisplay
        }
    }
}
