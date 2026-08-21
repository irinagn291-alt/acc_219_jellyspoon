import Foundation

@MainActor
final class MealPr {
    let logs: LogMgr

    init(logs: LogMgr) {
        self.logs = logs
    }

    func snap(day: Date = Date()) -> MealSnap {
        let key = DayKey.stamp(day)
        let rows = logs.eaten(day: key)
        var bySlot: [BiteSlot: Double] = [:]
        var kcal = 0.0, prot = 0.0, carb = 0.0, fat = 0.0
        for row in rows {
            kcal += row.kcal
            prot += row.prot
            carb += row.carb
            fat += row.fat
            bySlot[row.slot, default: 0] += row.kcal
        }
        return MealSnap(kcal: kcal, prot: prot, carb: carb, fat: fat, aim: logs.aim, bySlot: bySlot)
    }
}
