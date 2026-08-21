import UIKit

final class MealPg: UIViewController, JellyPaint {
    @IBOutlet private weak var bgArt: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var kcalLbl: UILabel!
    @IBOutlet private weak var protLbl: UILabel!
    @IBOutlet private weak var carbLbl: UILabel!
    @IBOutlet private weak var fatLbl: UILabel!
    @IBOutlet private weak var slotBox: UIStackView!
    @IBOutlet private weak var seekBtn: UIButton!
    @IBOutlet private weak var scanBtn: UIButton!
    @IBOutlet private weak var hintLbl: UILabel!
    @IBOutlet private weak var macroCard: UIView!

    private let pr: MealPr
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = MealPr(logs: logs)
        super.init(nibName: "MealPg", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        seekBtn.addTarget(self, action: #selector(tapSeek), for: .touchUpInside)
        scanBtn.addTarget(self, action: #selector(tapScan), for: .touchUpInside)
        paint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paint()
    }

    func paint() {
        Jelly.paper(view)
        Jelly.clipArt(bgArt, name: "SplashArt", sys: "fork.knife")
        bgArt.alpha = Jelly.hi ? 0.12 : 1
        Jelly.card(macroCard)
        Jelly.dress(titleLbl, size: 28, weight: .bold)
        titleLbl.text = "Today bowl"
        let s = pr.snap()
        Jelly.dress(kcalLbl, size: 24, weight: .bold, color: Jelly.berry)
        kcalLbl.text = "\(Int(s.kcal)) / \(Int(s.aim.kcal)) kcal"
        kcalLbl.accessibilityLabel = "Calories today, \(Int(s.kcal)) of \(Int(s.aim.kcal))"
        fill(protLbl, name: "Protein", now: s.prot, aim: s.aim.prot, color: Jelly.mint)
        fill(carbLbl, name: "Carbs", now: s.carb, aim: s.aim.carb, color: Jelly.orange)
        fill(fatLbl, name: "Fat", now: s.fat, aim: s.aim.fat, color: Jelly.grape)
        Jelly.dress(seekBtn, title: "Seek a jar", hint: "Opens name search and the local shelf")
        Jelly.dress(scanBtn, title: "Scan a pack", fill: Jelly.mint, hint: "Opens camera or manual code")
        Jelly.dress(hintLbl, size: 13, color: Jelly.mute)
        hintLbl.text = "Search a name or scan a pack"
        hintLbl.textAlignment = .center
        slotBox.arrangedSubviews.forEach { $0.removeFromSuperview() }
        slotBox.axis = .horizontal
        slotBox.distribution = .fillEqually
        slotBox.spacing = 8
        slotBox.alignment = .fill
        for slot in BiteSlot.allCases {
            let k = Int(s.bySlot[slot] ?? 0)
            let short = slot.title.split(separator: " ").first.map(String.init) ?? slot.title
            slotBox.addArrangedSubview(
                Jelly.chip(title: short, art: slot.art, sys: slot.sys, detail: "\(k) kcal", a11y: "\(slot.title), \(k) kcal logged")
            )
        }
    }

    private func fill(_ lbl: UILabel, name: String, now: Double, aim: Double, color: UIColor) {
        Jelly.dress(lbl, size: 13, weight: .medium, color: color)
        lbl.text = "\(name)\n\(Int(now)) / \(Int(aim))"
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.accessibilityLabel = "\(name) today, \(Int(now)) of \(Int(aim)) grams"
    }

    @objc private func tapSeek() { go?.seekFood() }
    @objc private func tapScan() { go?.scanPack() }
}
