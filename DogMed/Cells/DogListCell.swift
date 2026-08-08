import UIKit

class DogListCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var medsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.cornerRadius = 24
        photoImageView.clipsToBounds = true
    }

    func configure(dog: Dog) {
        nameLabel.text = dog.name
        detailLabel.text = "\(dog.breed) • \(dog.age) yrs"
        let count = dog.activeMedicationCount
        medsLabel.text = count == 1 ? "1 active medication" : "\(count) active medications"
        photoImageView.image = dog.image ?? UIImage(systemName: "pawprint.circle.fill")
    }
}
