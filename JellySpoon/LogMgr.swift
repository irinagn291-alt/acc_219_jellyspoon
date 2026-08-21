import Foundation

@MainActor
final class LogMgr {
    static let shared = LogMgr()

    private let defs: UserDefaults
    private let url: URL
    private let kBoot = "jelly.didBoot"
    private let kHi = "jelly.hiContrast"
    private let kSeed = "jelly.seeded"
    private let kAim = "jelly.aim"

    var scoops: [Scoop] = []
    var wishes: [Jar] = []
    var aim: Aim = .fresh
    var didBoot = false
    var hiContrast = false
    var seeded = false

    init(defs: UserDefaults = .standard, file: String = "jelly_log.plist") {
        self.defs = defs
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.url = docs.appendingPathComponent(file)
        load()
    }

    func load() {
        didBoot = defs.bool(forKey: kBoot)
        hiContrast = defs.bool(forKey: kHi)
        seeded = defs.bool(forKey: kSeed)
        if let data = defs.data(forKey: kAim), let decoded = try? JSONDecoder().decode(Aim.self, from: data) {
            aim = decoded
        } else {
            aim = .fresh
        }
        if let data = try? Data(contentsOf: url),
           let box = try? PropertyListDecoder().decode(JellyBox.self, from: data) {
            scoops = box.scoops
            wishes = box.wishes
        }
    }

    func save() {
        defs.set(didBoot, forKey: kBoot)
        defs.set(hiContrast, forKey: kHi)
        defs.set(seeded, forKey: kSeed)
        if let data = try? JSONEncoder().encode(aim) {
            defs.set(data, forKey: kAim)
        }
        let box = JellyBox(scoops: scoops, wishes: wishes)
        if let data = try? PropertyListEncoder().encode(box) {
            try? data.write(to: url, options: .atomic)
        }
    }

    func addScoop(_ scoop: Scoop) {
        scoops.append(scoop)
        save()
    }

    func dropScoop(_ id: UUID) {
        scoops.removeAll { $0.id == id }
        save()
    }

    @discardableResult
    func addWish(_ jar: Jar) -> Bool {
        if wishes.contains(where: { $0.sku == jar.sku }) { return false }
        wishes.append(jar)
        save()
        return true
    }

    func dropWish(_ sku: String) {
        wishes.removeAll { $0.sku == sku }
        save()
    }

    func eaten(day: String) -> [Scoop] {
        scoops.filter { $0.day == day && !$0.planned }
    }

    func planned(day: String) -> [Scoop] {
        scoops.filter { $0.day == day && $0.planned }
    }

    func seedDemoIfNeeded() {
        #if targetEnvironment(simulator)
        if seeded && eaten(day: DayKey.stamp(Date())).isEmpty {
            seeded = false
        }
        #endif
        guard !seeded else { return }
        let today = DayKey.stamp(Date())
        let soon = DayKey.stamp(DayKey.day(1))
        addScoop(Scoop(id: UUID(), day: today, slot: .sunrise, jar: Shelf.jars[0], grams: 90, planned: false))
        addScoop(Scoop(id: UUID(), day: today, slot: .picnic, jar: Shelf.jars[3], grams: 280, planned: false))
        addScoop(Scoop(id: UUID(), day: today, slot: .treat, jar: Shelf.jars[4], grams: 120, planned: false))
        addScoop(Scoop(id: UUID(), day: soon, slot: .sunrise, jar: Shelf.jars[6], grams: 80, planned: true))
        addScoop(Scoop(id: UUID(), day: soon, slot: .picnic, jar: Shelf.jars[2], grams: 40, planned: true))
        _ = addWish(Shelf.jars[7])
        _ = addWish(Shelf.jars[5])
        seeded = true
        save()
    }
}
