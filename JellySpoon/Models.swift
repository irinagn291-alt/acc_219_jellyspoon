import Foundation

enum BiteSlot: String, Codable, CaseIterable, Sendable {
    case sunrise, picnic, supper, treat

    var title: String {
        switch self {
        case .sunrise: "Sunrise bowl"
        case .picnic: "Lunch picnic"
        case .supper: "Supper pot"
        case .treat: "Treat"
        }
    }

    var forPlan: Bool { self != .treat }

    var art: String {
        switch self {
        case .sunrise: "SlotSunrise"
        case .picnic: "SlotPicnic"
        case .supper: "SlotSupper"
        case .treat: "SlotTreat"
        }
    }

    var sys: String {
        switch self {
        case .sunrise: "sunrise.fill"
        case .picnic: "basket.fill"
        case .supper: "frying.pan.fill"
        case .treat: "birthday.cake.fill"
        }
    }
}

struct Jar: Codable, Equatable, Hashable, Sendable {
    var sku: String
    var title: String
    var kcal100: Double
    var prot100: Double
    var carb100: Double
    var fat100: Double
    var imgKey: String
}

struct Scoop: Codable, Equatable, Identifiable, Sendable {
    var id: UUID
    var day: String
    var slot: BiteSlot
    var jar: Jar
    var grams: Double
    var planned: Bool

    var kcal: Double { ScoopMath.scale(jar.kcal100, grams) }
    var prot: Double { ScoopMath.scale(jar.prot100, grams) }
    var carb: Double { ScoopMath.scale(jar.carb100, grams) }
    var fat: Double { ScoopMath.scale(jar.fat100, grams) }
}

enum ScoopMath: Sendable {
    static func scale(_ per100: Double, _ grams: Double) -> Double {
        per100 * grams / 100
    }
}

struct Aim: Codable, Equatable, Sendable {
    var kcal: Double
    var prot: Double
    var carb: Double
    var fat: Double

    static let fresh = Aim(kcal: 2150, prot: 98, carb: 248, fat: 68)
}

enum DayKey: Sendable {
    static func stamp(_ d: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }

    static func day(_ offset: Int, from base: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: base) ?? base
    }

    static func pretty(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: d)
    }
}

enum Shelf: Sendable {
    static let jars: [Jar] = [
        Jar(sku: "js-oats", title: "Berry oats jar", kcal100: 372, prot100: 13, carb100: 62, fat100: 7, imgKey: "PackOats"),
        Jar(sku: "js-egg", title: "Sunny egg pair", kcal100: 148, prot100: 12, carb100: 1, fat100: 11, imgKey: "PackEgg"),
        Jar(sku: "js-cheese", title: "Picnic cheese wedge", kcal100: 356, prot100: 22, carb100: 2, fat100: 29, imgKey: "PackCheese"),
        Jar(sku: "js-soup", title: "Garden pot soup", kcal100: 48, prot100: 3, carb100: 7, fat100: 1, imgKey: "PackSoup"),
        Jar(sku: "js-apple", title: "Crunch apple", kcal100: 54, prot100: 0, carb100: 14, fat100: 0, imgKey: "PackApple"),
        Jar(sku: "js-cocoa", title: "Cocoa puff cloud", kcal100: 392, prot100: 6, carb100: 84, fat100: 4, imgKey: "PackCocoa"),
        Jar(sku: "js-toast", title: "Jelly toast slice", kcal100: 318, prot100: 8, carb100: 56, fat100: 6, imgKey: "PackToast"),
        Jar(sku: "js-fizz", title: "Lemon fizz bottle", kcal100: 38, prot100: 0, carb100: 10, fat100: 0, imgKey: "PackFizz"),
    ]
}

struct MealSnap: Equatable, Sendable {
    var kcal: Double
    var prot: Double
    var carb: Double
    var fat: Double
    var aim: Aim
    var bySlot: [BiteSlot: Double]
}

struct JellyBox: Codable, Sendable {
    var scoops: [Scoop]
    var wishes: [Jar]
}
