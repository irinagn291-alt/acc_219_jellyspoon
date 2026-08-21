import Foundation

@MainActor
final class PlanPr {
    let logs: LogMgr

    init(logs: LogMgr) {
        self.logs = logs
    }

    func rows(offset: Int) -> [Scoop] {
        logs.planned(day: DayKey.stamp(DayKey.day(offset)))
    }

    func drop(_ id: UUID) {
        logs.dropScoop(id)
    }
}
