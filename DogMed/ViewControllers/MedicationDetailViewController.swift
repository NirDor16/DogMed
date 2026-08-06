import UIKit

class MedicationDetailViewController: UIViewController {

    var medication: Medication!

    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let notesLabel = UILabel()
    private let vetLabel = UILabel()
    private let historyHeaderLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)

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
        view.backgroundColor = .systemBackground
        title = medication.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        setupLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func setupLayout() {
        [nameLabel, detailLabel, notesLabel, vetLabel].forEach { $0.numberOfLines = 0 }
        nameLabel.font = .boldSystemFont(ofSize: 22)
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.textColor = .secondaryLabel
        notesLabel.font = .systemFont(ofSize: 15)
        vetLabel.font = .systemFont(ofSize: 14)
        vetLabel.textColor = .secondaryLabel

        historyHeaderLabel.text = "RECENT HISTORY"
        historyHeaderLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        historyHeaderLabel.textColor = .secondaryLabel

        let headerStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel, notesLabel, vetLabel, historyHeaderLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.setCustomSpacing(16, after: vetLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground

        view.addSubview(headerStack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

    @objc private func editTapped() {
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        guard !rows.isEmpty else {
            cell.textLabel?.text = "No history yet"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        let row = rows[indexPath.row]
        let dateString = DateUtils.displayDateFormatter.string(from: row.date)
        cell.textLabel?.text = "\(dateString) — \(row.occurrence.time)"
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
