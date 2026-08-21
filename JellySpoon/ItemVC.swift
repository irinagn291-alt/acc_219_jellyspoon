import UIKit

final class ItemVC: UIViewController {
    @IBOutlet private weak var art: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var perLbl: UILabel!
    @IBOutlet private weak var biteLbl: UILabel!
    @IBOutlet private weak var gramSlider: UISlider!
    @IBOutlet private weak var gramLbl: UILabel!
    @IBOutlet private weak var wishBtn: UIButton!
    @IBOutlet private weak var nextBtn: UIButton!

    private let pr: ItemPr
    private let wish: WishPr
    weak var go: KitchenGo?

    init(jar: Jar, go: KitchenGo?, logs: LogMgr) {
        self.pr = ItemPr(jar: jar)
        self.wish = WishPr(logs: logs)
        self.go = go
        super.init(nibName: "ItemVC", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Jar card"
        Jelly.paper(view)
        Jelly.clipArt(art, name: pr.jar.imgKey.isEmpty ? "ChromeFrame" : pr.jar.imgKey, sys: "carrot.fill")
        art.isAccessibilityElement = true
        art.accessibilityLabel = pr.jar.title
        Jelly.dress(titleLbl, size: 24, weight: .bold)
        titleLbl.text = pr.jar.title
        Jelly.dress(perLbl, size: 15, color: Jelly.mute)
        perLbl.text = "Per 100 g · \(Int(pr.jar.kcal100)) kcal · P \(Int(pr.jar.prot100)) C \(Int(pr.jar.carb100)) F \(Int(pr.jar.fat100))"
        gramSlider.minimumValue = 20
        gramSlider.maximumValue = 400
        gramSlider.value = Float(pr.grams)
        gramSlider.accessibilityLabel = "Portion grams"
        gramSlider.accessibilityHint = "Adjusts the scoop size"
        Jelly.fat(gramSlider, min: 44)
        gramSlider.addTarget(self, action: #selector(slide), for: .valueChanged)
        Jelly.dress(wishBtn, title: "Wish this jar", fill: Jelly.grape, hint: "Saves the SKU if it is not already wished")
        Jelly.dress(nextBtn, title: "Pick a slot", hint: "Choose Sunrise bowl, picnic, supper, or treat")
        wishBtn.addTarget(self, action: #selector(tapWish), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(tapNext), for: .touchUpInside)
        paintBite()
    }

    @objc private func slide() {
        pr.grams = Double(gramSlider.value.rounded())
        paintBite()
    }

    private func paintBite() {
        let b = pr.bite()
        Jelly.dress(gramLbl, size: 16, weight: .semibold)
        gramLbl.text = "\(Int(pr.grams)) g scoop"
        gramLbl.accessibilityLabel = "Portion \(Int(pr.grams)) grams"
        Jelly.dress(biteLbl, size: 15, weight: .medium, color: Jelly.berry)
        biteLbl.text = "This scoop · \(Int(b.kcal)) kcal · P \(Int(b.prot)) C \(Int(b.carb)) F \(Int(b.fat))"
        biteLbl.accessibilityLabel = "Scoop \(Int(b.kcal)) calories, protein \(Int(b.prot)), carbs \(Int(b.carb)), fat \(Int(b.fat))"
    }

    @objc private func tapWish() {
        let ok = wish.add(pr.jar)
        let a = UIAlertController(title: ok ? "Wished" : "Already in the jar shelf", message: pr.jar.title, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc private func tapNext() {
        go?.assign(pr.jar, grams: pr.grams)
    }
}
