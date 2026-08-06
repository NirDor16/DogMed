import UIKit
import PhotosUI

class AddEditDogViewController: UIViewController {

    var dog: Dog?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let photoImageView = UIImageView()
    private let choosePhotoButton = UIButton(type: .system)
    private let nameField = UITextField()
    private let breedField = UITextField()
    private let ageField = UITextField()
    private let notesTextView = UITextView()

    private var pickedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = dog == nil ? "Add Dog" : "Edit Dog"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        setupForm()
        populateFields()
    }

    private func setupForm() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 45
        photoImageView.backgroundColor = .secondarySystemBackground
        photoImageView.tintColor = .secondaryLabel
        photoImageView.image = UIImage(systemName: "pawprint.circle.fill")

        choosePhotoButton.setTitle("Choose Photo", for: .normal)
        choosePhotoButton.addTarget(self, action: #selector(choosePhotoTapped), for: .touchUpInside)

        let nameStack = labeledRow(title: "Name", field: nameField)
        let breedStack = labeledRow(title: "Breed", field: breedField)
        ageField.keyboardType = .numberPad
        let ageStack = labeledRow(title: "Age (years)", field: ageField)

        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.font = .systemFont(ofSize: 16)
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let notesLabel = UILabel()
        notesLabel.text = "Notes"
        notesLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        notesLabel.textColor = .secondaryLabel

        let notesStack = UIStackView(arrangedSubviews: [notesLabel, notesTextView])
        notesStack.axis = .vertical
        notesStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [photoImageView, choosePhotoButton, nameStack, breedStack, ageStack, notesStack])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.alignment = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.setCustomSpacing(4, after: photoImageView)

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            photoImageView.widthAnchor.constraint(equalToConstant: 90),
            photoImageView.heightAnchor.constraint(equalToConstant: 90),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func labeledRow(title: String, field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel

        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
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

    @objc private func choosePhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveTapped() {
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

        navigationItem.rightBarButtonItem?.isEnabled = false
        let completion: (Error?) -> Void = { [weak self] error in
            DispatchQueue.main.async {
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
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
