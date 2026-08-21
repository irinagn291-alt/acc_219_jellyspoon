import UIKit

// MVP + Coordinator: XIBs stay dumb views, presenters own kitchen math,
// this object owns swipe pages and modal Search → Detail → Assign so views never push.

@MainActor
final class AppCoord: KitchenGo {
    let win: UIWindow
    let logs: LogMgr
    private var nav: UINavigationController?
    private var host: PageHost?

    init(win: UIWindow, logs: LogMgr = .shared) {
        self.win = win
        self.logs = logs
    }

    func start() {
        logs.load()
        logs.seedDemoIfNeeded()
        if logs.didBoot {
            showMain()
        } else {
            showBoot()
        }
    }

    func showBoot() {
        win.rootViewController = BootVC(go: self)
        win.makeKeyAndVisible()
    }

    func bootDone() {
        logs.didBoot = true
        logs.save()
        showMain()
    }

    func showMain() {
        let host = PageHost(go: self, logs: logs)
        self.host = host
        let nav = UINavigationController(rootViewController: host)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        self.nav = nav
        win.rootViewController = nav
        win.makeKeyAndVisible()
    }

    func seekFood() {
        presentFlow(SeekVC(go: self, logs: logs))
    }

    func scanPack() {
        presentFlow(ScanVC(go: self, logs: logs))
    }

    func openJar(_ jar: Jar) {
        let item = ItemVC(jar: jar, go: self, logs: logs)
        if let n = topNav() {
            n.pushViewController(item, animated: true)
        } else {
            presentFlow(item)
        }
    }

    func openCode(_ code: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                self.openJar(try await OffNet.jar(code: code))
            } catch {
                self.ping("That code did not jiggle a product.")
            }
        }
    }

    func assign(_ jar: Jar, grams: Double) {
        topNav()?.pushViewController(SlotVC(jar: jar, grams: grams, go: self, logs: logs), animated: true)
    }

    func parked(planned: Bool) {
        nav?.dismiss(animated: true) { [weak self] in
            self?.host?.reloadAll()
            self?.host?.jump(to: planned ? 2 : 0)
        }
    }

    func closeFlow() {
        nav?.dismiss(animated: true)
    }

    private func presentFlow(_ vc: UIViewController) {
        let n = UINavigationController(rootViewController: vc)
        n.modalPresentationStyle = .fullScreen
        n.navigationBar.prefersLargeTitles = false
        let look = UINavigationBarAppearance()
        look.configureWithOpaqueBackground()
        look.backgroundColor = Jelly.cream
        look.shadowColor = .clear
        look.titleTextAttributes = [
            .font: Jelly.type(17, weight: .semibold),
            .foregroundColor: Jelly.ink,
        ]
        n.navigationBar.standardAppearance = look
        n.navigationBar.scrollEdgeAppearance = look
        n.navigationBar.tintColor = Jelly.ink
        nav?.present(n, animated: true)
    }

    private func topNav() -> UINavigationController? {
        nav?.presentedViewController as? UINavigationController
    }

    private func ping(_ msg: String) {
        let a = UIAlertController(title: "Oops", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        (nav?.presentedViewController ?? nav)?.present(a, animated: true)
    }
}
