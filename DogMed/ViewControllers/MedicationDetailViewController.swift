import UIKit

class MedicationDetailViewController: UIViewController {

    var medication: Medication!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var vetLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var currentMedication: Medication {
        for dog in FirebaseManager.shared.dogs where dog.id == medication.dogId {
            if let updated = dog.medications.first(where: { $0.id == medication.id }) {
                return updated
            }
        }
        return medication
    }

    private var historyRows: [(date: Date, occurrence: MedicationOccurrence)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dates = (0..<14).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
        let med = currentMedication
        var rows: [(Date, MedicationOccurrence)] = []
        for date in dates {
            for occurrence in med.occurrences(on: date) {
                rows.append((date, occurrence))
            }
        }
        return rows
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = medication.name
        view.backgroundColor = .systemBackground
        detailLabel.textColor = .secondaryLabel
        vetLabel.textColor = .secondaryLabel
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    @objc private func reloadData() {
        let med = currentMedication
        nameLabel.text = med.name
        let times = med.scheduledTimes.sorted().joined(separator: ", ")
        let range = "From \(DateUtils.displayString(fromKey: med.startDate))" + (med.endDate.map { " to \(DateUtils.displayString(fromKey: $0))" } ?? " (ongoing)")
        detailLabel.text = "\(med.dosage) • \(times) • \(med.frequencySummary)\n\(range)"
        notesLabel.text = med.notes.isEmpty ? "No notes" : med.notes
        vetLabel.text = med.vetName.map { "Vet: \($0)" } ?? ""
        tableView.reloadData()
    }

    @IBAction func editTapped() {
        performSegue(withIdentifier: "editMedication", sender: currentMedication)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMedication", let destination = segue.destination as? AddEditMedicationViewController {
            destination.medication = sender as? Medication
        }
    }
}

extension MedicationDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyRows.isEmpty ? 1 : historyRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = historyRows
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        guard !rows.isEmpty else {
            cell.textLabel?.text = "No history yet"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.detailTextLabel?.text = nil
            cell.selectionStyle = .none
            return cell
        }
        let row = rows[indexPath.row]
        let dateString = DateUtils.displayDateFormatter.string(from: row.date)
        cell.textLabel?.text = "\(dateString) — \(row.occurrence.time)"
        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .natural
        cell.selectionStyle = .default
        cell.detailTextLabel?.text = row.occurrence.status.displayName
        cell.detailTextLabel?.textColor = row.occurrence.status == .given ? .systemGreen : .systemOrange
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rows = historyRows
        guard !rows.isEmpty else { return }
        let row = rows[indexPath.row]
        let dateKey = DateUtils.key(from: row.date)
        let newGiven = row.occurrence.status == .pending
        FirebaseManager.shared.setMedication(currentMedication, given: newGiven, on: dateKey, time: row.occurrence.time) { error in
            if let error = error {
                print("DogMed: failed to update history: \(error.localizedDescription)")
            }
        }
    }
}
