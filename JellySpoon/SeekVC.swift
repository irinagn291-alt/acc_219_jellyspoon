import UIKit

final class SeekVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private weak var search: UISearchBar!
    @IBOutlet private weak var table: UITableView!
    @IBOutlet private weak var busy: UIActivityIndicatorView!

    private let pr: SeekPr
    weak var go: KitchenGo?

    init(go: KitchenGo?, logs: LogMgr) {
        self.go = go
        self.pr = SeekPr(logs: logs)
        super.init(nibName: "SeekVC", bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("no") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seek a jar"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.accessibilityLabel = "Close search"
        Jelly.paper(view)
        search.delegate = self
        search.placeholder = "Name a food"
        search.searchTextField.font = Jelly.type(16, weight: .regular)
        table.rowHeight = 72
        table.estimatedRowHeight = 72
        table.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 16)
        search.searchTextField.adjustsFontForContentSizeCategory = true
        search.accessibilityLabel = "Search foods by name"
        table.dataSource = self
        table.delegate = self
        table.register(RowCell.self, forCellReuseIdentifier: RowCell.id)
        table.rowHeight = 72
        table.estimatedRowHeight = 72
        table.backgroundColor = .clear
        table.accessibilityLabel = "Shelf and search hits"
        busy.hidesWhenStopped = true
        busy.accessibilityLabel = "Searching"
    }

    @objc private func close() { go?.closeFlow() }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        Task { [weak self] in
            guard let self else { return }
            self.busy.startAnimating()
            await self.pr.run(searchBar.text ?? "")
            self.busy.stopAnimating()
            self.table.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? pr.shelf.count : pr.hits.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Local shelf" : "Open Food Facts"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RowCell.id, for: indexPath) as! RowCell
        let jar = indexPath.section == 0 ? pr.shelf[indexPath.row] : pr.hits[indexPath.row]
        let detail = "\(Int(jar.kcal100)) kcal · P \(Int(jar.prot100)) C \(Int(jar.carb100)) F \(Int(jar.fat100)) / 100 g"
        cell.fill(title: jar.title, detail: detail, art: jar.imgKey.isEmpty ? "ChromeFrame" : jar.imgKey, sys: "carrot.fill", a11y: "\(jar.title), \(detail)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let jar = indexPath.section == 0 ? pr.shelf[indexPath.row] : pr.hits[indexPath.row]
        go?.openJar(jar)
    }
}
