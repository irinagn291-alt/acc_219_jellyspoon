import UIKit

extension Notification.Name {
    static let jellyPaint = Notification.Name("jelly.paint")
}

@MainActor
enum Jelly {
    static var hi: Bool { LogMgr.shared.hiContrast }

    static var cream: UIColor { hi ? .white : UIColor(named: "CreamBg") ?? UIColor(red: 1, green: 0.97, blue: 0.90, alpha: 1) }
    static var ink: UIColor { hi ? .black : UIColor(red: 0.18, green: 0.10, blue: 0.16, alpha: 1) }
    static var berry: UIColor { hi ? UIColor(red: 0.55, green: 0, blue: 0.12, alpha: 1) : UIColor(red: 0.86, green: 0.24, blue: 0.42, alpha: 1) }
    static var lemon: UIColor { hi ? UIColor(red: 0.72, green: 0.55, blue: 0, alpha: 1) : UIColor(red: 1, green: 0.84, blue: 0.32, alpha: 1) }
    static var mint: UIColor { hi ? UIColor(red: 0, green: 0.38, blue: 0.36, alpha: 1) : UIColor(red: 0.18, green: 0.64, blue: 0.60, alpha: 1) }
    static var grape: UIColor { hi ? UIColor(red: 0.28, green: 0.12, blue: 0.55, alpha: 1) : UIColor(red: 0.54, green: 0.42, blue: 0.84, alpha: 1) }
    static var orange: UIColor { hi ? UIColor(red: 0.70, green: 0.28, blue: 0, alpha: 1) : UIColor(red: 0.92, green: 0.46, blue: 0.20, alpha: 1) }
    static var line: UIColor { hi ? .black : UIColor(red: 0.18, green: 0.10, blue: 0.16, alpha: 0.10) }
    static var panel: UIColor { hi ? .white : UIColor(white: 1, alpha: 0.92) }
    static var mute: UIColor { ink.withAlphaComponent(0.55) }

    static func type(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let rounded = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: rounded, size: size)
    }

    static func art(_ name: String, sys: String) -> UIImage {
        if UIAccessibility.isVoiceOverRunning || hi {
            if let symbol = UIImage(systemName: sys) {
                return symbol.withRenderingMode(.alwaysTemplate)
            }
        }
        return UIImage(named: name) ?? UIImage(systemName: sys) ?? UIImage()
    }

    static func thumb(_ name: String, sys: String, side: CGFloat = 52) -> UIImage {
        let img = art(name, sys: sys)
        guard img.size.width > 1, img.size.height > 1 else { return img }
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let r = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return r.image { _ in
            let rect = CGRect(x: 0, y: 0, width: side, height: side)
            UIBezierPath(roundedRect: rect, cornerRadius: min(12, side * 0.22)).addClip()
            let scale = max(side / img.size.width, side / img.size.height)
            let w = img.size.width * scale
            let h = img.size.height * scale
            img.draw(in: CGRect(x: (side - w) / 2, y: (side - h) / 2, width: w, height: h))
        }.withRenderingMode(.alwaysOriginal)
    }

    static func dress(_ label: UILabel, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor? = nil) {
        label.font = type(size, weight: weight)
        label.adjustsFontForContentSizeCategory = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.textColor = color ?? ink
        label.numberOfLines = 0
        label.backgroundColor = .clear
    }

    static func dress(_ btn: UIButton, title: String, fill: UIColor? = nil, ink inkColor: UIColor? = nil, label: String? = nil, hint: String? = nil) {
        var cfg = UIButton.Configuration.filled()
        cfg.title = title
        cfg.baseBackgroundColor = fill ?? berry
        cfg.baseForegroundColor = inkColor ?? .white
        cfg.cornerStyle = .capsule
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        cfg.titleLineBreakMode = .byTruncatingTail
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = type(16, weight: .semibold)
            return out
        }
        btn.configuration = cfg
        pinH(btn, 48)
        btn.accessibilityLabel = label ?? title
        btn.accessibilityHint = hint
        btn.accessibilityTraits.insert(.button)
    }

    static func paper(_ view: UIView) {
        view.backgroundColor = cream
        view.layer.contents = nil
        view.viewWithTag(0x4A454C31)?.removeFromSuperview()
    }

    static func card(_ view: UIView) {
        view.backgroundColor = panel
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = hi ? 0 : 0.06
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
    }

    static func pinH(_ view: UIView, _ min: CGFloat) {
        if view.constraints.contains(where: { $0.identifier == "jelly.h" }) { return }
        let c = view.heightAnchor.constraint(greaterThanOrEqualToConstant: min)
        c.identifier = "jelly.h"
        c.isActive = true
    }

    static func fat(_ view: UIView, min: CGFloat = 44) {
        pinH(view, min)
    }

    static func clipArt(_ iv: UIImageView, name: String, sys: String) {
        iv.image = art(name, sys: sys)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
    }

    static func chip(title: String, art name: String, sys: String, detail: String, a11y: String) -> UIView {
        let box = UIView()
        box.backgroundColor = panel
        box.layer.cornerRadius = 16
        box.layer.masksToBounds = true
        let iv = UIImageView(image: thumb(name, sys: sys, side: 72))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        let nameLbl = UILabel()
        dress(nameLbl, size: 12, weight: .semibold)
        nameLbl.text = title
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 1
        let det = UILabel()
        dress(det, size: 11, weight: .medium, color: berry)
        det.text = detail
        det.textAlignment = .center
        det.numberOfLines = 1
        let col = UIStackView(arrangedSubviews: [iv, nameLbl, det])
        col.axis = .vertical
        col.alignment = .fill
        col.spacing = 4
        col.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(col)
        NSLayoutConstraint.activate([
            iv.heightAnchor.constraint(equalToConstant: 44),
            col.topAnchor.constraint(equalTo: box.topAnchor, constant: 8),
            col.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 6),
            col.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -6),
            col.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -8),
        ])
        box.isAccessibilityElement = true
        box.accessibilityLabel = a11y
        return box
    }
}

@MainActor
protocol JellyPaint: AnyObject {
    func paint()
}

@MainActor
protocol KitchenGo: AnyObject {
    func bootDone()
    func seekFood()
    func scanPack()
    func openJar(_ jar: Jar)
    func openCode(_ code: String)
    func assign(_ jar: Jar, grams: Double)
    func parked(planned: Bool)
    func closeFlow()
}

final class RowCell: UITableViewCell {
    static let id = "row"
    private let thumb = UIImageView()
    private let titleLbl = UILabel()
    private let detailLbl = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .default
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 12
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        detailLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.numberOfLines = 1
        detailLbl.numberOfLines = 2
        contentView.addSubview(thumb)
        contentView.addSubview(titleLbl)
        contentView.addSubview(detailLbl)
        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumb.widthAnchor.constraint(equalToConstant: 52),
            thumb.heightAnchor.constraint(equalToConstant: 52),
            thumb.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: thumb.bottomAnchor, constant: 10),
            titleLbl.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            titleLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            detailLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            detailLbl.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor),
            detailLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 3),
            detailLbl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func fill(title: String, detail: String, art: String, sys: String, a11y: String) {
        titleLbl.font = Jelly.type(16, weight: .semibold)
        detailLbl.font = Jelly.type(13, weight: .regular)
        titleLbl.textColor = Jelly.ink
        detailLbl.textColor = Jelly.mute
        titleLbl.text = title
        detailLbl.text = detail
        thumb.image = Jelly.thumb(art, sys: sys, side: 52)
        thumb.tintColor = Jelly.berry
        accessibilityLabel = a11y
        accessibilityTraits = .button
    }
}
