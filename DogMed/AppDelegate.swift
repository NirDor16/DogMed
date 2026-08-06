import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    /// Forward orientation support to the visible view controller via AdaptiveNavigationController.
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

/// Navigation controller that delegates orientation support to its visible child.
class AdaptiveNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    override var shouldAutorotate: Bool { true }
}
