import Foundation

@MainActor
final class SeekPr {
    let logs: LogMgr
    private(set) var hits: [Jar] = []

    init(logs: LogMgr) {
        self.logs = logs
        _ = logs.aim
    }

    var shelf: [Jar] { Shelf.jars }

    func run(_ q: String) async {
        let t = q.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else {
            hits = []
            return
        }
        do {
            hits = try await OffNet.seek(t)
        } catch {
            hits = []
        }
    }
}
