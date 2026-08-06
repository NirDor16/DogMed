import UIKit

final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}

    enum AppearanceMode: Int {
        case system = 0
        case light = 1
        case dark = 2

        var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .system: return .unspecified
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    private let key = "dogMedAppearanceMode"

    var mode: AppearanceMode {
        get { AppearanceMode(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .system }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply()
        }
    }

    func apply() {
        let style = mode.userInterfaceStyle
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
