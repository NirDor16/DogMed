import UIKit

class MedicationListCell: UITableViewCell {

    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        accessoryType = .disclosureIndicator

        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 2

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        statusLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textStack)
        contentView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),

            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
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
