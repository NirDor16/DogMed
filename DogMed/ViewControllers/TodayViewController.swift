import UIKit

struct TodayRow {
    let dog: Dog
    let medication: Medication
    let occurrence: MedicationOccurrence
}

class TodayViewController: UITableViewController {

    private let reuseIdentifier = "TodayMedicationCell"
    private var rows: [TodayRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Today"
        tableView.register(TodayMedicationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = .systemGroupedBackground

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    @objc private func reloadData() {
        let today = Date()
        var newRows: [TodayRow] = []
        for dog in FirebaseManager.shared.dogs {
            for medication in dog.medications {
                for occurrence in medication.occurrences(on: today) {
                    newRows.append(TodayRow(dog: dog, medication: medication, occurrence: occurrence))
                }
            }
        }
        let sorted = newRows.sorted { $0.occurrence.time < $1.occurrence.time }
        DispatchQueue.main.async { [weak self] in
            self?.rows = sorted
            self?.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.isEmpty ? 1 : rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !rows.isEmpty else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No medications scheduled for today"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TodayMedicationCell
        let row = rows[indexPath.row]
        cell.configure(row: row) { [weak self] in
            self?.toggleGiven(row: row)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !rows.isEmpty else { return }
        toggleGiven(row: rows[indexPath.row])
    }

    private func toggleGiven(row: TodayRow) {
        let dateKey = DateUtils.key(from: Date())
        let newGiven = row.occurrence.status == .pending
        FirebaseManager.shared.setMedication(row.medication, given: newGiven, on: dateKey, time: row.occurrence.time) { error in
            if let error = error {
                print("DogMed: failed to update medication status: \(error.localizedDescription)")
            }
        }
    }
}
