import UIKit

final class WishPg: UIViewController, JellyPaint, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var emptyArt: UIImageView!
    @IBOutlet private weak var emptyLbl: UILabel!
    @IBOutlet private weak var table: UITableView!

    private let pr: WishPr
    private var rows: [Jar] = []
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = WishPr(logs: logs)
        super.init(nibName: "WishPg", bundle: nil)
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
        table.accessibilityLabel = "Wish jars"
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
        titleLbl.text = "Wish jars"
        rows = pr.list()
        Jelly.clipArt(emptyArt, name: "EmptyJar", sys: "heart")
        emptyArt.isHidden = !rows.isEmpty
        emptyArt.accessibilityLabel = "Empty wish shelf"
        emptyArt.isAccessibilityElement = rows.isEmpty
        Jelly.dress(emptyLbl, size: 15, color: Jelly.mute)
        emptyLbl.text = "No wishes yet. Heart a jar on its card."
        emptyLbl.isHidden = !rows.isEmpty
        table.isHidden = rows.isEmpty
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.id, for: indexPath) as! RowCell
        let j = rows[indexPath.row]
        let detail = "\(Int(j.kcal100)) kcal / 100 g"
        cell.fill(title: j.title, detail: detail, art: j.imgKey.isEmpty ? "ChromeFrame" : j.imgKey, sys: "heart.fill", a11y: "\(j.title), \(detail)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        go?.openJar(rows[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let drop = UIContextualAction(style: .destructive, title: "Drop") { [weak self] _, _, done in
            guard let self else { return }
            self.pr.drop(self.rows[indexPath.row].sku)
            self.paint()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [drop])
    }
}
