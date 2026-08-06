import UIKit

class DogDetailViewController: UIViewController {

    var dog: Dog!

    private let headerView = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let breedAgeLabel = UILabel()
    private let notesLabel = UILabel()
    private let addMedicationButton = UIButton(type: .system)
    private let medicationsHeaderLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let reuseIdentifier = "MedicationListCell"

    private var currentDog: Dog {
        FirebaseManager.shared.dogs.first { $0.id == dog.id } ?? dog
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = dog.name
        setupHeader()
        setupTable()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editDogTapped))
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.tintColor = .secondaryLabel
        imageView.backgroundColor = .secondarySystemBackground

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 22)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center

        breedAgeLabel.translatesAutoresizingMaskIntoConstraints = false
        breedAgeLabel.font = .systemFont(ofSize: 15)
        breedAgeLabel.textColor = .secondaryLabel
        breedAgeLabel.textAlignment = .center

        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.font = .systemFont(ofSize: 14)
        notesLabel.textColor = .label
        notesLabel.numberOfLines = 0
        notesLabel.textAlignment = .center

        addMedicationButton.translatesAutoresizingMaskIntoConstraints = false
        addMedicationButton.setTitle("+ Add Medication", for: .normal)
        addMedicationButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        addMedicationButton.addTarget(self, action: #selector(addMedicationTapped), for: .touchUpInside)

        medicationsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        medicationsHeaderLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        medicationsHeaderLabel.textColor = .secondaryLabel
        medicationsHeaderLabel.text = "MEDICATIONS"

        [imageView, nameLabel, breedAgeLabel, notesLabel, addMedicationButton, medicationsHeaderLabel].forEach { headerView.addSubview($0) }

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            imageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            breedAgeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            breedAgeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            breedAgeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            notesLabel.topAnchor.constraint(equalTo: breedAgeLabel.bottomAnchor, constant: 8),
            notesLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            notesLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            addMedicationButton.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 12),
            addMedicationButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            medicationsHeaderLabel.topAnchor.constraint(equalTo: addMedicationButton.bottomAnchor, constant: 12),
            medicationsHeaderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            medicationsHeaderLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            medicationsHeaderLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MedicationListCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func reloadData() {
        let updated = currentDog
        nameLabel.text = updated.name
        breedAgeLabel.text = "\(updated.breed) • \(updated.age) yrs"
        notesLabel.text = updated.notes.isEmpty ? "No notes" : updated.notes
        imageView.image = updated.image ?? UIImage(systemName: "pawprint.circle.fill")
        tableView.reloadData()
    }

    @objc private func editDogTapped() {
        performSegue(withIdentifier: "editDog", sender: currentDog)
    }

    @objc private func addMedicationTapped() {
        performSegue(withIdentifier: "showAddMedication", sender: currentDog)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDog", let destination = segue.destination as? AddEditDogViewController {
            destination.dog = sender as? Dog
        } else if segue.identifier == "showAddMedication", let destination = segue.destination as? AddEditMedicationViewController {
            destination.dogId = (sender as? Dog)?.id
        } else if segue.identifier == "showMedicationDetail", let destination = segue.destination as? MedicationDetailViewController {
            destination.medication = sender as? Medication
        }
    }
}

extension DogDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = currentDog.medications.count
        return count == 0 ? 1 : count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let medications = currentDog.medications
        guard !medications.isEmpty else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No medications yet"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MedicationListCell
        cell.configure(medication: medications[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let medications = currentDog.medications
        guard !medications.isEmpty else { return }
        performSegue(withIdentifier: "showMedicationDetail", sender: medications[indexPath.row])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        !currentDog.medications.isEmpty
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let medication = currentDog.medications[indexPath.row]
        FirebaseManager.shared.deleteMedication(medication) { error in
            if let error = error {
                print("DogMed: failed to delete medication: \(error.localizedDescription)")
            }
        }
    }
}
