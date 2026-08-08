import UIKit

class TodayMedicationCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!

    private var onToggle: (() -> Void)?

    func configure(row: TodayRow, onToggle: @escaping () -> Void) {
        timeLabel.text = row.occurrence.time
        titleLabel.text = "\(row.dog.name) — \(row.medication.name)"
        subtitleLabel.text = row.medication.dosage
        let given = row.occurrence.status == .given
        statusButton.setTitle(given ? "Given" : "Mark Given", for: .normal)
        statusButton.tintColor = given ? .systemGreen : .systemOrange
        self.onToggle = onToggle
    }

    @IBAction func statusTapped(_ sender: UIButton) {
        onToggle?()
    }
}
