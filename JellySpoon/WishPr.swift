import Foundation

@MainActor
final class WishPr {
    let logs: LogMgr

    init(logs: LogMgr) {
        self.logs = logs
    }

    func list() -> [Jar] { logs.wishes }

    @discardableResult
    func add(_ jar: Jar) -> Bool {
        logs.addWish(jar)
    }

    func drop(_ sku: String) {
        logs.dropWish(sku)
    }
}
