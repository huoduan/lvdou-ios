import Foundation

enum LocalStore {
    private static let d = UserDefaults.standard

    static var token: String? {
        get { d.string(forKey: "token") }
        set { d.setValue(newValue, forKey: "token") }
    }

    static var user: UserInfo? {
        get { load("user", UserInfo.self) }
        set { save("user", newValue) }
    }

    static var history: [HistoryItem] {
        get { load("history", [HistoryItem].self) ?? [] }
        set { save("history", Array(newValue.prefix(100))) }
    }

    static var favorites: [Vod] {
        get { load("favorites", [Vod].self) ?? [] }
        set { save("favorites", newValue) }
    }

    static func addHistory(_ item: HistoryItem) {
        var list = history.filter { $0.vodId != item.vodId }
        list.insert(item, at: 0)
        history = list
    }

    static func toggleFavorite(_ vod: Vod) {
        var list = favorites
        if let i = list.firstIndex(where: { $0.vod_id == vod.vod_id }) {
            list.remove(at: i)
        } else {
            list.append(vod)
        }
        favorites = list
    }

    static func isFavorite(_ vod: Vod) -> Bool {
        favorites.contains { $0.vod_id == vod.vod_id }
    }

    private static func load<T: Decodable>(_ key: String, _ t: T.Type) -> T? {
        guard let data = d.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save<T: Encodable>(_ key: String, _ v: T?) {
        guard let v else { d.removeObject(forKey: key); return }
        d.setValue(try? JSONEncoder().encode(v), forKey: key)
    }
}
