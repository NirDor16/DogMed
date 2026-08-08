import UIKit

class DogDetailViewController: UIViewController {

    var dog: Dog!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedAgeLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIBarButtonItem!

    private let reuseIdentifier = "MedicationListCell"

    private var currentDog: Dog {
        FirebaseManager.shared.dogs.first { $0.id == dog.id } ?? dog
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = dog.name
        view.backgroundColor = .systemBackground
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        breedAgeLabel.textColor = .secondaryLabel
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        deleteButton.tintColor = .systemRed

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    @objc private func reloadData() {
        let updated = currentDog
        nameLabel.text = updated.name
        breedAgeLabel.text = "\(updated.breed) • \(updated.age) yrs"
        notesLabel.text = updated.notes.isEmpty ? "No notes" : updated.notes
        imageView.image = updated.image ?? UIImage(systemName: "pawprint.circle.fill")
        tableView.reloadData()
    }

    @IBAction func editDogTapped() {
        performSegue(withIdentifier: "editDog", sender: currentDog)
    }

    @IBAction func addMedicationTapped() {
        performSegue(withIdentifier: "showAddMedication", sender: currentDog)
    }

    @IBAction func deleteDogTapped() {
        let dog = currentDog
        let alert = UIAlertController(
            title: "Delete \(dog.name)?",
            message: "This will permanently delete \(dog.name) and all of its medications.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            FirebaseManager.shared.deleteDog(dog) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.showAlert(message: error.localizedDescription)
                        return
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        present(alert, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "DogMed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
