import Foundation

/// Vendored EAN / QR digit helper. Pulls 8–14 digits from raw text or URL payloads.
public enum DigitGrab: Sendable {
    public static func scoopCode(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let viaURL = fromURL(trimmed) {
            return viaURL
        }
        return normalize(digits(in: trimmed))
    }

    public static func digits(in raw: String) -> String {
        raw.filter(\.isNumber)
    }

    public static func normalize(_ digitsOnly: String) -> String? {
        var d = digitsOnly
        if d.count == 12 {
            d = "0" + d
        }
        guard (8...14).contains(d.count) else { return nil }
        return d
    }

    public static func fromURL(_ raw: String) -> String? {
        guard let url = URL(string: raw), url.scheme != nil else { return nil }
        let keys: Set<String> = ["ean", "ean13", "ean_13", "gtin", "code", "barcode"]
        if let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in items {
                guard keys.contains(item.name.lowercased()), let value = item.value else { continue }
                if let code = normalize(digits(in: value)) { return code }
            }
        }
        for part in url.pathComponents.reversed() {
            if let code = normalize(digits(in: part)) { return code }
        }
        return normalize(digits(in: raw))
    }
}
