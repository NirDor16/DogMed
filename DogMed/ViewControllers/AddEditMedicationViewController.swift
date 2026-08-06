import UIKit

class AddEditMedicationViewController: UIViewController {

    var dogId: String?
    var medication: Medication?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let nameField = UITextField()
    private let dosageField = UITextField()
    private let frequencyControl = UISegmentedControl(items: ["Once a day", "Twice a day", "Specific days"])
    private let time1Picker = UIDatePicker()
    private let time1Label = UILabel()
    private let time2Row = UIStackView()
    private let time2Picker = UIDatePicker()
    private let weekdaysStack = UIStackView()
    private let weekdaysRow = UIStackView()
    private var weekdayButtons: [UIButton] = []
    private let startDatePicker = UIDatePicker()
    private let hasEndDateSwitch = UISwitch()
    private let endDateRow = UIStackView()
    private let endDatePicker = UIDatePicker()
    private let notesTextView = UITextView()
    private let vetNameField = UITextField()

    private let weekdayTitles = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var selectedWeekdays: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = medication == nil ? "Add Medication" : "Edit Medication"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        setupForm()
        populateFields()
        updateVisibility()
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

        let nameStack = labeledRow(title: "Medication Name", field: nameField)
        let dosageStack = labeledRow(title: "Dosage", field: dosageField)

        frequencyControl.selectedSegmentIndex = 0
        frequencyControl.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        let frequencyStack = UIStackView(arrangedSubviews: [sectionLabel("Frequency"), frequencyControl])
        frequencyStack.axis = .vertical
        frequencyStack.spacing = 4

        time1Picker.datePickerMode = .time
        time1Picker.preferredDatePickerStyle = .compact
        time1Label.text = "Time"
        time1Label.font = .systemFont(ofSize: 13, weight: .semibold)
        time1Label.textColor = .secondaryLabel
        let time1Row = UIStackView(arrangedSubviews: [time1Label, time1Picker])
        time1Row.axis = .horizontal
        time1Row.distribution = .equalSpacing

        time2Picker.datePickerMode = .time
        time2Picker.preferredDatePickerStyle = .compact
        let time2Label = UILabel()
        time2Label.text = "Time 2"
        time2Label.font = .systemFont(ofSize: 13, weight: .semibold)
        time2Label.textColor = .secondaryLabel
        time2Row.axis = .horizontal
        time2Row.distribution = .equalSpacing
        time2Row.addArrangedSubview(time2Label)
        time2Row.addArrangedSubview(time2Picker)

        weekdayButtons = (0..<7).map { index in
            let button = UIButton(type: .system)
            button.setTitle(weekdayTitles[index], for: .normal)
            button.tag = index + 1
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.separator.cgColor
            button.addTarget(self, action: #selector(weekdayTapped(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 40).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            return button
        }
        weekdaysRow.axis = .horizontal
        weekdaysRow.spacing = 4
        weekdaysRow.distribution = .fillEqually
        weekdayButtons.forEach {
            weekdaysRow.addArrangedSubview($0)
            setWeekdayButton($0, selected: false)
        }
        weekdaysStack.axis = .vertical
        weekdaysStack.spacing = 4
        weekdaysStack.addArrangedSubview(sectionLabel("Days of the Week"))
        weekdaysStack.addArrangedSubview(weekdaysRow)

        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        let startDateRow = UIStackView(arrangedSubviews: [sectionLabel("Start Date"), startDatePicker])
        startDateRow.axis = .horizontal
        startDateRow.distribution = .equalSpacing

        hasEndDateSwitch.addTarget(self, action: #selector(endDateSwitchChanged), for: .valueChanged)
        let endDateSwitchRow = UIStackView(arrangedSubviews: [sectionLabel("Has End Date"), hasEndDateSwitch])
        endDateSwitchRow.axis = .horizontal
        endDateSwitchRow.distribution = .equalSpacing

        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDateRow.axis = .horizontal
        endDateRow.distribution = .equalSpacing
        endDateRow.addArrangedSubview(sectionLabel("End Date"))
        endDateRow.addArrangedSubview(endDatePicker)

        let vetStack = labeledRow(title: "Veterinarian (optional)", field: vetNameField)

        notesTextView.font = .systemFont(ofSize: 16)
        notesTextView.layer.borderColor = UIColor.separator.cgColor
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.cornerRadius = 8
        notesTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let notesStack = UIStackView(arrangedSubviews: [sectionLabel("Notes"), notesTextView])
        notesStack.axis = .vertical
        notesStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [
            nameStack, dosageStack, frequencyStack, time1Row, time2Row, weekdaysStack,
            startDateRow, endDateSwitchRow, endDateRow, vetStack, notesStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func labeledRow(title: String, field: UITextField) -> UIStackView {
        let label = sectionLabel(title)
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
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
        time2Row.isHidden = index != 1
        weekdaysStack.isHidden = index != 2
        endDateRow.isHidden = !hasEndDateSwitch.isOn
    }

    @objc private func frequencyChanged() {
        updateVisibility()
    }

    @objc private func endDateSwitchChanged() {
        updateVisibility()
    }

    @objc private func weekdayTapped(_ sender: UIButton) {
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

    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveTapped() {
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
