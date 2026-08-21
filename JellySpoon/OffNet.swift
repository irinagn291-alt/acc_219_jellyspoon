import Foundation

enum OffFail: Error {
    case badURL
    case nope
}

private enum FlexNum: Decodable {
    case n(Double)
    case other

    init(from decoder: Decoder) throws {
        let box = try decoder.singleValueContainer()
        if let d = try? box.decode(Double.self) {
            self = .n(d)
            return
        }
        if let i = try? box.decode(Int.self) {
            self = .n(Double(i))
            return
        }
        if let s = try? box.decode(String.self), let d = Double(s) {
            self = .n(d)
            return
        }
        self = .other
    }

    var d: Double {
        if case .n(let v) = self { return v }
        return 0
    }
}

private struct OffSeek: Decodable {
    var products: [OffProd]
}

private struct OffOne: Decodable {
    var status: Int
    var product: OffProd?
}

private struct OffProd: Decodable {
    var code: String?
    var product_name: String?
    var nutriments: [String: FlexNum]?
}

enum OffNet {
    static let ua = "JellySpoon/1.0 (iOS; com.jellyspoon.kitchen; health-fitness tracker)"

    static func seek(_ q: String) async throws -> [Jar] {
        var c = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        c?.queryItems = [
            URLQueryItem(name: "search_terms", value: q),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "24"),
        ]
        guard let url = c?.url else { throw OffFail.badURL }
        let box = try JSONDecoder().decode(OffSeek.self, from: try await pull(url))
        return box.products.compactMap(Jar.init(off:))
    }

    static func jar(code: String) async throws -> Jar {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(code).json") else {
            throw OffFail.badURL
        }
        let box = try JSONDecoder().decode(OffOne.self, from: try await pull(url))
        guard box.status == 1, let p = box.product, let jar = Jar(off: p) else { throw OffFail.nope }
        return jar
    }

    private static func pull(_ url: URL) async throws -> Data {
        var req = URLRequest(url: url)
        req.setValue(ua, forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw OffFail.nope
        }
        return data
    }
}

private extension Jar {
    init?(off p: OffProd) {
        let sku = (p.code ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let title = (p.product_name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sku.isEmpty, !title.isEmpty else { return nil }
        let n = p.nutriments ?? [:]
        let kcalRaw = n["energy-kcal_100g"]?.d ?? 0
        let kj = n["energy-kj_100g"]?.d ?? n["energy_100g"]?.d ?? 0
        let kcal = kcalRaw > 0 ? kcalRaw : (kj > 0 ? kj / 4.184 : 0)
        self.init(
            sku: sku,
            title: title,
            kcal100: kcal,
            prot100: n["proteins_100g"]?.d ?? 0,
            carb100: n["carbohydrates_100g"]?.d ?? 0,
            fat100: n["fat_100g"]?.d ?? 0,
            imgKey: ""
        )
    }
}
