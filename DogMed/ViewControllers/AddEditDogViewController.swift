import UIKit
import PhotosUI

class AddEditDogViewController: UIViewController {

    var dog: Dog?

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var breedField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = dog == nil ? "Add Dog" : "Edit Dog"
        view.backgroundColor = .systemBackground
        photoImageView.layer.cornerRadius = photoImageView.bounds.width / 2
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .secondarySystemBackground
        notesTextView.backgroundColor = .systemBackground
        notesTextView.textColor = .label
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        populateFields()
    }

    private func populateFields() {
        guard let dog = dog else { return }
        nameField.text = dog.name
        breedField.text = dog.breed
        ageField.text = "\(dog.age)"
        notesTextView.text = dog.notes
        if let image = dog.image {
            photoImageView.image = image
        }
    }

    @IBAction func choosePhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty else {
            showAlert(message: "Please enter a dog name.")
            return
        }
        let breed = breedField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let age = Int(ageField.text ?? "") ?? 0
        let notes = notesTextView.text ?? ""

        var photoBase64 = dog?.photoBase64
        if let pickedImage = pickedImage {
            photoBase64 = ImageUtils.base64String(from: pickedImage)
        }

        let id = dog?.id ?? ""
        let newDog = Dog(id: id, name: name, breed: breed, age: age, notes: notes, photoBase64: photoBase64, medications: dog?.medications ?? [])

        saveButton.isEnabled = false
        let completion: (Error?) -> Void = { [weak self] error in
            DispatchQueue.main.async {
                self?.saveButton.isEnabled = true
                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }

        if dog == nil {
            FirebaseManager.shared.addDog(newDog, completion: completion)
        } else {
            FirebaseManager.shared.updateDog(newDog, completion: completion)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "DogMed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddEditDogViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                self?.pickedImage = image
                self?.photoImageView.image = image
            }
        }
    }
}
