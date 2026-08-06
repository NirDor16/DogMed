import UIKit

class DogListCell: UITableViewCell {

    private let photoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let medsLabel = UILabel()

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

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 24
        photoImageView.backgroundColor = .secondarySystemBackground
        photoImageView.tintColor = .secondaryLabel

        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = .label

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel

        medsLabel.font = .systemFont(ofSize: 13)
        medsLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, detailLabel, medsLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(photoImageView)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            photoImageView.widthAnchor.constraint(equalToConstant: 48),
            photoImageView.heightAnchor.constraint(equalToConstant: 48),

            textStack.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 12),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(dog: Dog) {
        nameLabel.text = dog.name
        detailLabel.text = "\(dog.breed) • \(dog.age) yrs"
        let count = dog.activeMedicationCount
        medsLabel.text = count == 1 ? "1 active medication" : "\(count) active medications"
        photoImageView.image = dog.image ?? UIImage(systemName: "pawprint.circle.fill")
    }
}
