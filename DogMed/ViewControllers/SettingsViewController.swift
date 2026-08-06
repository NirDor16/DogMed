import UIKit

class SettingsViewController: UIViewController {

    private let segmentedControl = UISegmentedControl(items: ["Light", "Dark", "System"])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        setupLayout()
    }

    private func setupLayout() {
        let appearanceLabel = UILabel()
        appearanceLabel.text = "Appearance"
        appearanceLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        appearanceLabel.textColor = .secondaryLabel

        segmentedControl.addTarget(self, action: #selector(appearanceChanged), for: .valueChanged)
        switch ThemeManager.shared.mode {
        case .light: segmentedControl.selectedSegmentIndex = 0
        case .dark: segmentedControl.selectedSegmentIndex = 1
        case .system: segmentedControl.selectedSegmentIndex = 2
        }

        let infoLabel = UILabel()
        infoLabel.text = "DogMed helps you keep track of your dogs' medications. It does not provide medical advice — always follow your veterinarian's instructions."
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [appearanceLabel, segmentedControl, infoLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(32, after: segmentedControl)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    @objc private func appearanceChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: ThemeManager.shared.mode = .light
        case 1: ThemeManager.shared.mode = .dark
        default: ThemeManager.shared.mode = .system
        }
    }
}
