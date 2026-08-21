import UIKit

final class SlotVC: UIViewController {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var nowBtn: UIButton!
    @IBOutlet private weak var planBtn: UIButton!
    @IBOutlet private weak var slotBox: UIStackView!
    @IBOutlet private weak var dayLbl: UILabel!
    @IBOutlet private weak var daySlider: UISlider!
    @IBOutlet private weak var doneBtn: UIButton!

    private let pr: SlotPr
    weak var go: KitchenGo?

    init(jar: Jar, grams: Double, go: KitchenGo?, logs: LogMgr) {
        self.pr = SlotPr(logs: logs, jar: jar, grams: grams)
        self.go = go
        super.init(nibName: "SlotVC", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Assign"
        Jelly.paper(view)
        Jelly.dress(titleLbl, size: 22, weight: .bold)
        titleLbl.text = "Where does this scoop sit?"
        nowBtn.addTarget(self, action: #selector(tapNow), for: .touchUpInside)
        planBtn.addTarget(self, action: #selector(tapPlan), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(tapDone), for: .touchUpInside)
        daySlider.minimumValue = 0
        daySlider.maximumValue = 6
        daySlider.value = 0
        daySlider.addTarget(self, action: #selector(slideDay), for: .valueChanged)
        daySlider.accessibilityLabel = "Plan day offset"
        Jelly.fat(daySlider, min: 44)
        slotBox.axis = .vertical
        slotBox.spacing = 8
        paintMode()
    }

    @objc private func tapNow() {
        pr.planned = false
        if pr.slot == .treat { }
        paintMode()
    }

    @objc private func tapPlan() {
        pr.planned = true
        if !pr.slot.forPlan { pr.slot = .sunrise }
        paintMode()
    }

    @objc private func slideDay() {
        pr.dayOffset = Int(daySlider.value.rounded())
        paintDay()
    }

    @objc private func tapDone() {
        pr.park()
        go?.parked(planned: pr.planned)
    }

    private func paintMode() {
        Jelly.dress(nowBtn, title: "Spoon it now", fill: pr.planned ? Jelly.panel : Jelly.berry, ink: pr.planned ? Jelly.ink : .white, hint: "Logs into today's bites. Treat is allowed.")
        Jelly.dress(planBtn, title: "Park on plan", fill: pr.planned ? Jelly.mint : Jelly.panel, ink: pr.planned ? .white : Jelly.ink, hint: "Plans Sunrise, picnic, or supper. Treat stays off the plan.")
        daySlider.isHidden = !pr.planned
        dayLbl.isHidden = !pr.planned
        paintDay()
        slotBox.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for slot in pr.slots {
            let b = UIButton(type: .system)
            var cfg = UIButton.Configuration.plain()
            cfg.title = slot.title
            cfg.image = Jelly.thumb(slot.art, sys: slot.sys, side: 40)
            cfg.imagePlacement = .leading
            cfg.imagePadding = 12
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 12)
            cfg.baseForegroundColor = Jelly.ink
            cfg.background.backgroundColor = slot == pr.slot ? Jelly.berry.withAlphaComponent(0.14) : Jelly.panel
            cfg.background.cornerRadius = 14
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = Jelly.type(16, weight: .semibold)
                return out
            }
            b.configuration = cfg
            b.contentHorizontalAlignment = .leading
            b.tag = pr.slots.firstIndex(of: slot) ?? 0
            b.addTarget(self, action: #selector(tapSlot(_:)), for: .touchUpInside)
            b.accessibilityLabel = slot.title
            b.accessibilityHint = "Assigns this scoop to \(slot.title)"
            Jelly.pinH(b, 56)
            slotBox.addArrangedSubview(b)
        }
        Jelly.dress(doneBtn, title: "Park this scoop", hint: "Saves the scoop into today or the picnic plan")
    }

    private func paintDay() {
        Jelly.dress(dayLbl, size: 15, weight: .medium, color: Jelly.mute)
        let d = DayKey.day(pr.dayOffset)
        dayLbl.text = "Plan day · \(DayKey.pretty(d))"
        dayLbl.accessibilityLabel = "Plan day \(DayKey.pretty(d))"
    }

    @objc private func tapSlot(_ sender: UIButton) {
        let slots = pr.slots
        guard slots.indices.contains(sender.tag) else { return }
        pr.slot = slots[sender.tag]
        paintMode()
    }
}
