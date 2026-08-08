import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        switch ThemeManager.shared.mode {
        case .light: segmentedControl.selectedSegmentIndex = 0
        case .dark: segmentedControl.selectedSegmentIndex = 1
        case .system: segmentedControl.selectedSegmentIndex = 2
        }
    }

    @IBAction func appearanceChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: ThemeManager.shared.mode = .light
        case 1: ThemeManager.shared.mode = .dark
        default: ThemeManager.shared.mode = .system
        }
    }
}
