import Foundation

@MainActor
final class BitePr {
    let logs: LogMgr

    init(logs: LogMgr) {
        self.logs = logs
    }

    func rows(day: Date = Date()) -> [Scoop] {
        logs.eaten(day: DayKey.stamp(day))
    }

    func drop(_ id: UUID) {
        logs.dropScoop(id)
    }
}
