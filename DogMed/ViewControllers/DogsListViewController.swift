import UIKit

class DogsListViewController: UITableViewController {

    private let reuseIdentifier = "DogListCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Dogs"
        tableView.register(DogListCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.backgroundColor = .systemGroupedBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .dogMedDataDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    @objc private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func addTapped() {
        performSegue(withIdentifier: "showAddDog", sender: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = FirebaseManager.shared.dogs.count
        return count == 0 ? 1 : count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dogs = FirebaseManager.shared.dogs
        guard !dogs.isEmpty else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "No dogs yet — tap + to add one"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! DogListCell
        cell.configure(dog: dogs[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dogs = FirebaseManager.shared.dogs
        guard !dogs.isEmpty else { return }
        performSegue(withIdentifier: "showDogDetail", sender: dogs[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        !FirebaseManager.shared.dogs.isEmpty
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let dog = FirebaseManager.shared.dogs[indexPath.row]
        FirebaseManager.shared.deleteDog(dog) { error in
            if let error = error {
                print("DogMed: failed to delete dog: \(error.localizedDescription)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDogDetail",
           let destination = segue.destination as? DogDetailViewController,
           let dog = sender as? Dog {
            destination.dog = dog
        }
    }
}
