import UIKit

final class DayCard: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var emptyArt: UIImageView!

    private let pr: PlanPr
    private let offset: Int
    private var rows: [Scoop] = []

    init(pr: PlanPr, offset: Int) {
        self.pr = pr
        self.offset = offset
        super.init(nibName: "DayCard", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.register(RowCell.self, forCellReuseIdentifier: RowCell.id)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 72
        paint()
    }

    func paint() {
        guard isViewLoaded else { return }
        Jelly.paper(view)
        table.backgroundColor = .clear
        let day = DayKey.day(offset)
        Jelly.dress(titleLbl, size: 20, weight: .semibold)
        titleLbl.text = DayKey.pretty(day)
        titleLbl.accessibilityLabel = "Plan for \(DayKey.pretty(day))"
        rows = pr.rows(offset: offset)
        emptyArt.image = Jelly.art("EmptyPicnic", sys: "calendar")
        emptyArt.isHidden = !rows.isEmpty
        emptyArt.accessibilityLabel = "Empty picnic plan"
        emptyArt.isAccessibilityElement = rows.isEmpty
        table.isHidden = rows.isEmpty
        table.reloadData()
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
