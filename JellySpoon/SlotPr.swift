import Foundation

@MainActor
final class SlotPr {
    let logs: LogMgr
    let jar: Jar
    let grams: Double
    var planned = false
    var dayOffset = 0
    var slot: BiteSlot = .sunrise

    init(logs: LogMgr, jar: Jar, grams: Double) {
        self.logs = logs
        self.jar = jar
        self.grams = grams
    }

    var slots: [BiteSlot] {
        planned ? BiteSlot.allCases.filter(\.forPlan) : BiteSlot.allCases
    }

    func park() {
        let day = DayKey.stamp(DayKey.day(planned ? dayOffset : 0))
        logs.addScoop(Scoop(id: UUID(), day: day, slot: slot, jar: jar, grams: grams, planned: planned))
    }
}
