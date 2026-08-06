import UIKit

class TodayMedicationCell: UITableViewCell {

    private let timeLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let statusButton = UIButton(type: .system)
    private var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none

        timeLabel.font = .boldSystemFont(ofSize: 16)
        timeLabel.textColor = .label
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel

        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        statusButton.addTarget(self, action: #selector(statusTapped), for: .touchUpInside)
        statusButton.setContentHuggingPriority(.required, for: .horizontal)
        statusButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(timeLabel)
        contentView.addSubview(textStack)
        contentView.addSubview(statusButton)

        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 52),

            textStack.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            statusButton.leadingAnchor.constraint(greaterThanOrEqualTo: textStack.trailingAnchor, constant: 8),
            statusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(row: TodayRow, onToggle: @escaping () -> Void) {
        timeLabel.text = row.occurrence.time
        titleLabel.text = "\(row.dog.name) — \(row.medication.name)"
        subtitleLabel.text = row.medication.dosage
        let given = row.occurrence.status == .given
        statusButton.setTitle(given ? "Given" : "Mark Given", for: .normal)
        statusButton.tintColor = given ? .systemGreen : .systemOrange
        self.onToggle = onToggle
    }

    @objc private func statusTapped() {
        onToggle?()
    }
}
