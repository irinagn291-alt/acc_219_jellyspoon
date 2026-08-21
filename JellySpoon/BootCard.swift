import UIKit

final class BootCard: UIViewController {
    @IBOutlet private weak var art: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var bodyLbl: UILabel!
    @IBOutlet private weak var doneBtn: UIButton!

    private var pack: Pack?
    weak var go: KitchenGo?
    var onAdvance: (() -> Void)?

    struct Pack {
        var img: String
        var sys: String
        var title: String
        var body: String
        var last: Bool
    }

    convenience init(pack: Pack, go: KitchenGo?) {
        self.init(nibName: "BootCard", bundle: nil)
        self.pack = pack
        self.go = go
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        paint()
    }

    func paint() {
        guard let pack else { return }
        Jelly.paper(view)
        Jelly.clipArt(art, name: pack.img, sys: pack.sys)
        art.isAccessibilityElement = true
        art.accessibilityLabel = pack.title
        Jelly.dress(titleLbl, size: 28, weight: .bold, color: Jelly.ink)
        Jelly.dress(bodyLbl, size: 17, color: Jelly.mute)
        titleLbl.text = pack.title
        bodyLbl.text = pack.body
        titleLbl.textAlignment = .center
        bodyLbl.textAlignment = .center
        doneBtn.isHidden = false
        Jelly.dress(
            doneBtn,
            title: pack.last ? "Open the kitchen" : "Next",
            hint: pack.last ? "Finishes onboarding and opens today" : "Shows the next onboarding page"
        )
        doneBtn.removeTarget(self, action: #selector(tapDone), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(tapDone), for: .touchUpInside)
    }

    @objc private func tapDone() {
        if pack?.last == true {
            go?.bootDone()
        } else {
            onAdvance?()
        }
    }
}
