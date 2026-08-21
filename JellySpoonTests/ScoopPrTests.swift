import XCTest
@testable import JellySpoon

@MainActor
final class ScoopPrTests: XCTestCase {
    func testGiven100gWhenScaleThenUnchanged() {
        // Given
        let per = 214.0
        // When
        let got = ScoopMath.scale(per, 100)
        // Then
        XCTAssertEqual(got, 214, accuracy: 0.001)
    }

    func testGiven80gWhenScaleThenFourFifths() {
        // Given
        let per = 250.0
        // When
        let got = ScoopMath.scale(per, 80)
        // Then
        XCTAssertEqual(got, 200, accuracy: 0.001)
    }

    func testWishRejectsDuplicateSKU() {
        // Given
        let defs = UserDefaults(suiteName: "jelly.test.\(UUID().uuidString)")!
        let logs = LogMgr(defs: defs, file: "jelly_test_\(UUID().uuidString).plist")
        logs.wishes = []
        let pr = WishPr(logs: logs)
        let jar = Shelf.jars[0]
        // When
        let first = pr.add(jar)
        let again = pr.add(jar)
        // Then
        XCTAssertTrue(first)
        XCTAssertFalse(again)
        XCTAssertEqual(pr.list().count, 1)
    }

    func testMealPrSumsEatenOnly() {
        // Given
        let defs = UserDefaults(suiteName: "jelly.test.\(UUID().uuidString)")!
        let logs = LogMgr(defs: defs, file: "jelly_meal_\(UUID().uuidString).plist")
        logs.scoops = []
        logs.aim = .fresh
        let today = DayKey.stamp(Date())
        let jar = Shelf.jars[0]
        logs.addScoop(Scoop(id: UUID(), day: today, slot: .sunrise, jar: jar, grams: 100, planned: false))
        logs.addScoop(Scoop(id: UUID(), day: today, slot: .sunrise, jar: jar, grams: 100, planned: true))
        let pr = MealPr(logs: logs)
        // When
        let snap = pr.snap()
        // Then
        XCTAssertEqual(snap.kcal, jar.kcal100, accuracy: 0.01)
    }

    func testScanPrReadsQRURLAndUPC12() {
        // Given
        let pr = ScanPr()
        let url = "https://world.openfoodfacts.org/product/3017620422003/x"
        // When / Then
        XCTAssertEqual(pr.digest(url), "3017620422003")
        XCTAssertEqual(pr.digest("123456789012"), "0123456789012")
        XCTAssertEqual(pr.digest("ean=5000112637939"), "5000112637939")
        XCTAssertNil(pr.digest("123"))
    }

    func testItemPrPortionMatchesScale() {
        // Given
        let jar = Shelf.jars[3]
        let pr = ItemPr(jar: jar, grams: 200)
        // When
        let bite = pr.bite()
        // Then
        XCTAssertEqual(bite.kcal, jar.kcal100 * 2, accuracy: 0.01)
    }
}
