import Foundation

@MainActor
final class GoalPr {
    let logs: LogMgr

    init(logs: LogMgr) {
        self.logs = logs
    }

    var hi: Bool { logs.hiContrast }

    func current() -> Aim { logs.aim }

    func save(_ aim: Aim) {
        logs.aim = aim
        logs.save()
        NotificationCenter.default.post(name: .jellyPaint, object: nil)
    }

    func setContrast(_ on: Bool) {
        logs.hiContrast = on
        logs.save()
        NotificationCenter.default.post(name: .jellyPaint, object: nil)
    }
}
