import UIKit

final class BitePg: UIViewController, JellyPaint, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var emptyArt: UIImageView!
    @IBOutlet private weak var emptyLbl: UILabel!
    @IBOutlet private weak var table: UITableView!

    private let pr: BitePr
    private var rows: [Scoop] = []
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = BitePr(logs: logs)
        super.init(nibName: "BitePg", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.register(RowCell.self, forCellReuseIdentifier: RowCell.id)
        table.rowHeight = 72
        table.estimatedRowHeight = 72
        table.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 16)
        table.accessibilityLabel = "Today's bites"
        paint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        paint()
    }

    func paint() {
        Jelly.paper(view)
        table.backgroundColor = .clear
        Jelly.dress(titleLbl, size: 28, weight: .bold)
        titleLbl.text = "Bites today"
        rows = pr.rows()
        Jelly.clipArt(emptyArt, name: "EmptyBowl", sys: "bowl.fill")
        emptyArt.isHidden = !rows.isEmpty
        emptyArt.isAccessibilityElement = rows.isEmpty
        emptyArt.accessibilityLabel = "Empty bowl"
        Jelly.dress(emptyLbl, size: 15, color: Jelly.mute)
        emptyLbl.text = "No scoops yet. Seek or scan from Today."
        emptyLbl.isHidden = !rows.isEmpty
        table.isHidden = rows.isEmpty
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.id, for: indexPath) as! RowCell
        let r = rows[indexPath.row]
        let detail = "\(r.slot.title) · \(Int(r.grams)) g · \(Int(r.kcal)) kcal"
        cell.fill(title: r.jar.title, detail: detail, art: r.jar.imgKey.isEmpty ? r.slot.art : r.jar.imgKey, sys: r.slot.sys, a11y: "\(r.jar.title), \(detail)")
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
