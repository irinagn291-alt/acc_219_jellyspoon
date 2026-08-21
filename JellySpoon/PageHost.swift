import UIKit

final class PageHost: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let pager = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pages: [UIViewController] = []
    private let tabs = UISegmentedControl(items: ["Today", "Bites", "Plan", "Wish", "Aims"])
    private let names = ["Today bowl", "Bites", "Picnic plan", "Wish jars", "Aims"]
    weak var go: KitchenGo?
    let logs: LogMgr
    private var idx = 0

    init(go: KitchenGo, logs: LogMgr) {
        self.go = go
        self.logs = logs
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        Jelly.paper(view)
        pages = [
            MealPg(go: go, logs: logs),
            BitePg(go: go, logs: logs),
            PlanPg(go: go, logs: logs),
            WishPg(go: go, logs: logs),
            GoalPg(go: go, logs: logs),
        ]
        addChild(pager)
        view.addSubview(pager.view)
        pager.view.translatesAutoresizingMaskIntoConstraints = false
        pager.didMove(toParent: self)
        pager.dataSource = self
        pager.delegate = self
        pager.setViewControllers([pages[0]], direction: .forward, animated: false)

        tabs.translatesAutoresizingMaskIntoConstraints = false
        tabs.selectedSegmentIndex = 0
        tabs.selectedSegmentTintColor = Jelly.berry
        tabs.setTitleTextAttributes([
            .font: Jelly.type(13, weight: .semibold),
            .foregroundColor: Jelly.ink,
        ], for: .normal)
        tabs.setTitleTextAttributes([
            .font: Jelly.type(13, weight: .semibold),
            .foregroundColor: UIColor.white,
        ], for: .selected)
        tabs.addTarget(self, action: #selector(tabJump), for: .valueChanged)
        view.addSubview(tabs)

        NSLayoutConstraint.activate([
            tabs.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            tabs.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tabs.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tabs.heightAnchor.constraint(equalToConstant: 34),
            pager.view.topAnchor.constraint(equalTo: view.topAnchor),
            pager.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        speakPage()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAll), name: .jellyPaint, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let extraTop = max(0, tabs.frame.maxY - view.safeAreaInsets.top + 8)
        if pager.additionalSafeAreaInsets.top != extraTop {
            pager.additionalSafeAreaInsets.top = extraTop
        }
    }

    @objc func reloadAll() {
        Jelly.paper(view)
        pages.forEach { ($0 as? JellyPaint)?.paint() }
        speakPage()
    }

    func jump(to i: Int) {
        guard pages.indices.contains(i) else { return }
        let dir: UIPageViewController.NavigationDirection = i >= idx ? .forward : .reverse
        pager.setViewControllers([pages[i]], direction: dir, animated: true)
        idx = i
        tabs.selectedSegmentIndex = i
        speakPage()
    }

    @objc private func tabJump() { jump(to: tabs.selectedSegmentIndex) }

    private func speakPage() {
        let name = names.indices.contains(idx) ? names[idx] : "Page"
        view.accessibilityLabel = "Kitchen page \(idx + 1) of \(pages.count), \(name)"
        UIAccessibility.post(notification: .screenChanged, argument: view.accessibilityLabel)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let i = pages.firstIndex(where: { $0 === viewController }), i > 0 else { return nil }
        return pages[i - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let i = pages.firstIndex(where: { $0 === viewController }), i + 1 < pages.count else { return nil }
        return pages[i + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = pageViewController.viewControllers?.first, let i = pages.firstIndex(where: { $0 === vc }) else { return }
        idx = i
        tabs.selectedSegmentIndex = i
        speakPage()
    }
}
