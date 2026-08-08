import UIKit

class AddEditMedicationViewController: UIViewController {

    var dogId: String?
    var medication: Medication?

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var dosageField: UITextField!
    @IBOutlet weak var frequencyControl: UISegmentedControl!
    @IBOutlet weak var time1Label: UILabel!
    @IBOutlet weak var time1Picker: UIDatePicker!
    @IBOutlet weak var time2Container: UIView!
    @IBOutlet weak var time2Picker: UIDatePicker!
    @IBOutlet weak var weekdaysContainer: UIView!
    @IBOutlet var weekdayButtons: [UIButton]!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var hasEndDateSwitch: UISwitch!
    @IBOutlet weak var endDateContainer: UIView!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var vetNameField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    private var selectedWeekdays: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = medication == nil ? "Add Medication" : "Edit Medication"
        view.backgroundColor = .systemBackground
        notesTextView.backgroundColor = .systemBackground
        notesTextView.textColor = .label
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        for button in weekdayButtons {
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.separator.cgColor
            setWeekdayButton(button, selected: false)
        }
        populateFields()
        updateVisibility()
    }

    private func populateFields() {
        guard let medication = medication else {
            hasEndDateSwitch.isOn = false
            startDatePicker.date = Date()
            return
        }
        nameField.text = medication.name
        dosageField.text = medication.dosage
        vetNameField.text = medication.vetName
        notesTextView.text = medication.notes

        switch medication.frequency {
        case .once: frequencyControl.selectedSegmentIndex = 0
        case .twice: frequencyControl.selectedSegmentIndex = 1
        case .specificDays: frequencyControl.selectedSegmentIndex = 2
        }

        let times = medication.scheduledTimes.sorted()
        if let first = times.first, let date = DateUtils.timeFormatter.date(from: first) {
            time1Picker.date = date
        }
        if times.count > 1, let date = DateUtils.timeFormatter.date(from: times[1]) {
            time2Picker.date = date
        }

        selectedWeekdays = Set(medication.weekdays)
        for button in weekdayButtons {
            setWeekdayButton(button, selected: selectedWeekdays.contains(button.tag))
        }

        if let startDate = DateUtils.date(from: medication.startDate) {
            startDatePicker.date = startDate
        }
        if let endDateString = medication.endDate, let endDate = DateUtils.date(from: endDateString) {
            hasEndDateSwitch.isOn = true
            endDatePicker.date = endDate
        } else {
            hasEndDateSwitch.isOn = false
        }
    }

    private func updateVisibility() {
        let index = frequencyControl.selectedSegmentIndex
        time1Label.text = index == 1 ? "Time 1" : "Time"
        time2Container.isHidden = index != 1
        weekdaysContainer.isHidden = index != 2
        endDateContainer.isHidden = !hasEndDateSwitch.isOn
    }

    @IBAction func frequencyChanged() {
        updateVisibility()
    }

    @IBAction func endDateSwitchChanged() {
        updateVisibility()
    }

    @IBAction func weekdayTapped(_ sender: UIButton) {
        let day = sender.tag
        if selectedWeekdays.contains(day) {
            selectedWeekdays.remove(day)
        } else {
            selectedWeekdays.insert(day)
        }
        setWeekdayButton(sender, selected: selectedWeekdays.contains(day))
    }

    private func setWeekdayButton(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? .systemBlue : .clear
        button.setTitleColor(selected ? .white : .label, for: .normal)
    }

    @IBAction func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveTapped() {
        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let dosage = dosageField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !name.isEmpty, !dosage.isEmpty else {
            showAlert(message: "Please enter a medication name and dosage.")
            return
        }

        let frequency: Frequency
        switch frequencyControl.selectedSegmentIndex {
        case 1: frequency = .twice
        case 2: frequency = .specificDays
        default: frequency = .once
        }

        if frequency == .specificDays && selectedWeekdays.isEmpty {
            showAlert(message: "Please select at least one day of the week.")
            return
        }

        var times = [DateUtils.timeFormatter.string(from: time1Picker.date)]
        if frequency == .twice {
            times.append(DateUtils.timeFormatter.string(from: time2Picker.date))
        }

        let startDateString = DateUtils.key(from: startDatePicker.date)
        let endDateString = hasEndDateSwitch.isOn ? DateUtils.key(from: endDatePicker.date) : nil
        let notes = notesTextView.text ?? ""
        let vetName = vetNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let resolvedDogId = medication?.dogId ?? dogId else {
            showAlert(message: "Missing dog reference.")
            return
        }

        let id = medication?.id ?? ""
        let history = medication?.history ?? [:]

        let newMedication = Medication(
            id: id, dogId: resolvedDogId, name: name, dosage: dosage, frequency: frequency,
            scheduledTimes: times, weekdays: frequency == .specificDays ? Array(selectedWeekdays) : [],
            startDate: startDateString, endDate: endDateString, notes: notes,
            vetName: (vetName?.isEmpty ?? true) ? nil : vetName, history: history
        )

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

        if medication == nil {
            FirebaseManager.shared.addMedication(newMedication, completion: completion)
        } else {
            FirebaseManager.shared.updateMedication(newMedication, completion: completion)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "DogMed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
