import SwiftUI
import UIKit

final class GoalPg: UIViewController, JellyPaint {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var kcalField: UITextField!
    @IBOutlet private weak var protField: UITextField!
    @IBOutlet private weak var carbField: UITextField!
    @IBOutlet private weak var fatField: UITextField!
    @IBOutlet private weak var saveBtn: UIButton!
    @IBOutlet private weak var contrastSw: UISwitch!
    @IBOutlet private weak var contrastLbl: UILabel!
    @IBOutlet private weak var hintLbl: UILabel!

    private let pr: GoalPr
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = GoalPr(logs: logs)
        super.init(nibName: "GoalPg", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.addTarget(self, action: #selector(tapSave), for: .touchUpInside)
        contrastSw.addTarget(self, action: #selector(tapContrast), for: .valueChanged)
        installContact()
        [kcalField, protField, carbField, fatField].forEach {
            $0?.keyboardType = .decimalPad
            $0?.adjustsFontForContentSizeCategory = true
            Jelly.pinH($0!, 48)
        }
        paint()
    }

    func paint() {
        Jelly.paper(view)
        Jelly.dress(titleLbl, size: 28, weight: .bold)
        titleLbl.text = "Aims"
        let a = pr.current()
        kcalField.text = "\(Int(a.kcal))"
        protField.text = "\(Int(a.prot))"
        carbField.text = "\(Int(a.carb))"
        fatField.text = "\(Int(a.fat))"
        kcalField.placeholder = "kcal"
        protField.placeholder = "protein g"
        carbField.placeholder = "carbs g"
        fatField.placeholder = "fat g"
        kcalField.accessibilityLabel = "Calorie aim"
        protField.accessibilityLabel = "Protein aim"
        carbField.accessibilityLabel = "Carb aim"
        fatField.accessibilityLabel = "Fat aim"
        [kcalField, protField, carbField, fatField].forEach {
            $0?.font = Jelly.type(18, weight: .medium)
            $0?.textColor = Jelly.ink
            $0?.backgroundColor = Jelly.panel
            $0?.layer.borderWidth = Jelly.hi ? 2 : 1
            $0?.layer.borderColor = Jelly.line.cgColor
            $0?.layer.cornerRadius = 12
            $0?.clipsToBounds = true
        }
        Jelly.dress(saveBtn, title: "Save aims", hint: "Stores calorie and macro aims")
        contrastSw.isOn = pr.hi
        contrastSw.onTintColor = Jelly.berry
        contrastSw.accessibilityLabel = "High contrast"
        contrastSw.accessibilityHint = "Boosts contrast and may swap art for symbols"
        Jelly.dress(contrastLbl, size: 16, weight: .medium)
        contrastLbl.text = "High contrast kitchen"
        Jelly.dress(hintLbl, size: 13, color: Jelly.mute)
        hintLbl.text = "Dynamic Type follows Settings."
    }

    @objc private func tapSave() {
        let aim = Aim(
            kcal: num(kcalField),
            prot: num(protField),
            carb: num(carbField),
            fat: num(fatField)
        )
        pr.save(aim)
        paint()
    }

    @objc private func tapContrast() {
        pr.setContrast(contrastSw.isOn)
        paint()
    }

    @objc private func tapContact() {
        present(UIHostingController(rootView: KitchenContactPane()), animated: true)
    }

    private func installContact() {
        guard let body = hintLbl.superview else { return }
        let contact = UIButton(type: .system)
        contact.translatesAutoresizingMaskIntoConstraints = false
        Jelly.dress(contact, title: "Contact Us", hint: "Opens the support page")
        contact.addTarget(self, action: #selector(tapContact), for: .touchUpInside)
        body.addSubview(contact)
        body.constraints.filter {
            ($0.firstItem === body && $0.firstAttribute == .bottom)
                || ($0.secondItem === body && $0.secondAttribute == .bottom)
        }.forEach { $0.isActive = false }
        NSLayoutConstraint.activate([
            contact.topAnchor.constraint(equalTo: hintLbl.bottomAnchor, constant: 16),
            contact.leadingAnchor.constraint(equalTo: hintLbl.leadingAnchor),
            contact.trailingAnchor.constraint(equalTo: hintLbl.trailingAnchor),
            body.bottomAnchor.constraint(equalTo: contact.bottomAnchor, constant: 16)
        ])
    }

    private func num(_ field: UITextField) -> Double {
        max(1, Double(field.text ?? "") ?? 1)
    }
}
