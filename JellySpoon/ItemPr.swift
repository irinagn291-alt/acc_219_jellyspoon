import Foundation

@MainActor
final class ItemPr {
    let jar: Jar
    var grams: Double

    init(jar: Jar, grams: Double = 120) {
        self.jar = jar
        self.grams = grams
    }

    func bite() -> (kcal: Double, prot: Double, carb: Double, fat: Double) {
        (
            ScoopMath.scale(jar.kcal100, grams),
            ScoopMath.scale(jar.prot100, grams),
            ScoopMath.scale(jar.carb100, grams),
            ScoopMath.scale(jar.fat100, grams)
        )
    }
}
