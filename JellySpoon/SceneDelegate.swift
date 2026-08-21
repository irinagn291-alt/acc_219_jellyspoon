import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var coord: AppCoord?
    private let bus = KitchenLaunchBus()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        let win = UIWindow(windowScene: ws)
        window = win
        bus.start(on: win) { [weak self] window in
            let c = AppCoord(win: window)
            self?.coord = c
            c.start()
        }
    }
}
