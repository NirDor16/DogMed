import UIKit

class MedicationListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
    }

    func configure(medication: Medication) {
        nameLabel.text = medication.name
        let times = medication.scheduledTimes.sorted().joined(separator: ", ")
        detailLabel.text = "\(medication.dosage) • \(times) • \(medication.frequencySummary)"
        let active = medication.isActive(on: Date())
        statusLabel.text = active ? "Active" : "Inactive"
        statusLabel.backgroundColor = (active ? UIColor.systemGreen : UIColor.systemGray).withAlphaComponent(0.2)
        statusLabel.textColor = active ? .systemGreen : .secondaryLabel
    }
}
