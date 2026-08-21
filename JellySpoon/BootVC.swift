import UIKit

final class BootVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var cards: [BootCard] = []
    private let dots = UIPageControl()
    weak var go: KitchenGo?

    convenience init(go: KitchenGo) {
        self.init(nibName: nil, bundle: nil)
        self.go = go
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Jelly.paper(view)
        let packs: [BootCard.Pack] = [
            .init(img: "BootA", sys: "door.left.hand.open", title: "Hey kitchen!", body: "JellySpoon keeps scoops of food in a bright, swipeable kitchen.", last: false),
            .init(img: "BootB", sys: "rectangle.stack", title: "Five kitchen pages", body: "Today, bites, picnic plan, wishes, then aims. Tabs up top, swipe works too.", last: false),
            .init(img: "BootC", sys: "barcode.viewfinder", title: "Peek a pack", body: "Search a name or scan a barcode. Portion math lives on the card.", last: false),
            .init(img: "BootD", sys: "accessibility", title: "Friendly taps", body: "VoiceOver labels, Dynamic Type, and a high-contrast switch live in Aims.", last: true),
        ]
        cards = packs.enumerated().map { index, pack in
            let card = BootCard(pack: pack, go: go)
            card.onAdvance = { [weak self] in self?.showNext(from: index) }
            return card
        }
        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        dots.translatesAutoresizingMaskIntoConstraints = false
        dots.numberOfPages = cards.count
        dots.currentPageIndicatorTintColor = Jelly.berry
        dots.pageIndicatorTintColor = Jelly.ink.withAlphaComponent(0.25)
        dots.accessibilityLabel = "Onboarding pages"
        view.addSubview(dots)
        NSLayoutConstraint.activate([
            pager.view.topAnchor.constraint(equalTo: view.topAnchor),
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dots.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dots.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            dots.heightAnchor.constraint(equalToConstant: 28),
        ])
        pager.didMove(toParent: self)
        pager.dataSource = self
        pager.delegate = self
        if let first = cards.first {
            pager.setViewControllers([first], direction: .forward, animated: false)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let extra = max(0, view.bounds.maxY - dots.frame.minY + 8)
        if pager.additionalSafeAreaInsets.bottom != extra {
            pager.additionalSafeAreaInsets.bottom = extra
        }
    }

    private func showNext(from index: Int) {
        let next = index + 1
        guard cards.indices.contains(next) else { return }
        pager.setViewControllers([cards[next]], direction: .forward, animated: true)
        dots.currentPage = next
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let i = cards.firstIndex(where: { $0 === viewController }), i > 0 else { return nil }
        return cards[i - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let i = cards.firstIndex(where: { $0 === viewController }), i + 1 < cards.count else { return nil }
        return cards[i + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let i = cards.firstIndex(where: { $0 === pageViewController.viewControllers?.first }) {
            dots.currentPage = i
        }
    }
}
