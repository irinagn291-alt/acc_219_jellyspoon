import UIKit

final class PlanPg: UIViewController, JellyPaint, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var hostBox: UIView!
    @IBOutlet private weak var emptyArt: UIImageView!

    private let table = UITableView(frame: .zero, style: .plain)
    private let emptyLbl = UILabel()
    private let days = UIStackView()
    private let pr: PlanPr
    private var offset = 0
    private var rows: [Scoop] = []
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = PlanPr(logs: logs)
        super.init(nibName: "PlanPg", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        days.axis = .horizontal
        days.distribution = .fillEqually
        days.spacing = 6
        days.translatesAutoresizingMaskIntoConstraints = false
        hostBox.addSubview(days)
        NSLayoutConstraint.activate([
            days.topAnchor.constraint(equalTo: hostBox.topAnchor),
            days.leadingAnchor.constraint(equalTo: hostBox.leadingAnchor, constant: 16),
            days.trailingAnchor.constraint(equalTo: hostBox.trailingAnchor, constant: -16),
            days.bottomAnchor.constraint(equalTo: hostBox.bottomAnchor),
        ])
        for i in 0..<7 {
            let b = UIButton(type: .system)
            b.tag = i
            b.addTarget(self, action: #selector(tapDay(_:)), for: .touchUpInside)
            days.addArrangedSubview(b)
        }
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.register(RowCell.self, forCellReuseIdentifier: RowCell.id)
        table.rowHeight = 72
        table.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 16)
        table.backgroundColor = .clear
        table.accessibilityLabel = "Picnic plan"
        view.addSubview(table)
        emptyLbl.translatesAutoresizingMaskIntoConstraints = false
        emptyLbl.textAlignment = .center
        view.addSubview(emptyLbl)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: hostBox.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            emptyLbl.topAnchor.constraint(equalTo: emptyArt.bottomAnchor, constant: 8),
            emptyLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        paint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paint()
    }

    func paint() {
        Jelly.paper(view)
        Jelly.dress(titleLbl, size: 28, weight: .bold)
        titleLbl.text = "Picnic plan"
        for (i, view) in days.arrangedSubviews.enumerated() {
            guard let b = view as? UIButton else { continue }
            let day = DayKey.day(i)
            let df = DateFormatter()
            df.dateFormat = "EEE"
            var cfg = UIButton.Configuration.filled()
            cfg.title = df.string(from: day)
            cfg.baseBackgroundColor = i == offset ? Jelly.berry : Jelly.panel
            cfg.baseForegroundColor = i == offset ? .white : Jelly.ink
            cfg.cornerStyle = .capsule
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 4)
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = Jelly.type(12, weight: .semibold)
                return out
            }
            b.configuration = cfg
            b.accessibilityLabel = DayKey.pretty(day)
        }
        rows = pr.rows(offset: offset)
        emptyArt.image = UIImage(named: "EmptyPicnic")
        emptyArt.contentMode = .scaleAspectFill
        emptyArt.clipsToBounds = true
        emptyArt.layer.cornerRadius = 16
        emptyArt.isHidden = !rows.isEmpty
        emptyArt.accessibilityLabel = "Empty picnic plan"
        emptyArt.isAccessibilityElement = rows.isEmpty
        Jelly.dress(emptyLbl, size: 15, color: Jelly.mute)
        emptyLbl.text = "Nothing parked for this day."
        emptyLbl.isHidden = !rows.isEmpty
        table.isHidden = rows.isEmpty
        table.reloadData()
    }

    @objc private func tapDay(_ sender: UIButton) {
        offset = sender.tag
        paint()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.id, for: indexPath) as! RowCell
        let r = rows[indexPath.row]
        let detail = "\(r.slot.title) · \(Int(r.grams)) g · \(Int(r.kcal)) kcal"
        cell.fill(title: r.jar.title, detail: detail, art: r.jar.imgKey.isEmpty ? r.slot.art : r.jar.imgKey, sys: r.slot.sys, a11y: "Planned \(r.jar.title), \(detail)")
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let drop = UIContextualAction(style: .destructive, title: "Drop") { [weak self] _, _, done in
            guard let self else { return }
            self.pr.drop(self.rows[indexPath.row].id)
            self.paint()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [drop])
    }
}
