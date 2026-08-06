import Foundation

enum DateUtils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func key(from date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        dateFormatter.date(from: key)
    }

    static func timeKey(from time: String) -> String {
        time.replacingOccurrences(of: ":", with: "")
    }

    static func displayString(fromKey key: String) -> String {
        guard let date = date(from: key) else { return key }
        return displayDateFormatter.string(from: date)
    }
}
