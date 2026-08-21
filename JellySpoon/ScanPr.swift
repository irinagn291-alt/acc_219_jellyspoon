import Foundation

@MainActor
final class ScanPr {
    func digest(_ raw: String) -> String? {
        DigitGrab.scoopCode(from: raw)
    }
}
