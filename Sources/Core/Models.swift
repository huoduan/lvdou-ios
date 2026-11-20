import Foundation

struct AppConfig: Codable {
    var logoimage: String?
    var splashimage: String?
    var backdropimage: String?
    var playerimage: String?
    var serviceimage: String?
    var key: String?
    var notice: String?
}

struct Vod: Identifiable, Codable, Hashable {
    var id: String { vod_id }
    var vod_id: String
    var vod_name: String
    var vod_pic: String? = nil
    var vod_remarks: String? = nil
    var vod_year: String? = nil
    var vod_area: String? = nil
    var vod_score: String? = nil
    var vod_content: String? = nil
    var vod_play_from: String? = nil
    var vod_play_url: String? = nil
    var type_name: String? = nil

    var picURL: URL? { vod_pic.flatMap { URL(string: $0) } }
}

struct HomeSection: Identifiable {
    var id = UUID()
    var title: String
    var vods: [Vod]
    enum CodingKeys: String, CodingKey { case title, vods }
}

struct PlayLine: Identifiable {
    var id: String { name }
    var name: String
    var episodes: [Episode]
}

struct Episode: Identifiable, Hashable {
    var id: String { "\(name)-\(url)" }
    var name: String
    var url: String
}

struct UserInfo: Codable {
    var id: Int?
    var username: String?
    var nickname: String?
    var avatar: String?
    var token: String?
    var group_id: Int?
    var group_name: String?
    var vipendtime: String?
    var score: String?
    var money: String?
}

struct BannerConfig: Codable, Identifiable {
    var id = UUID()
    var title: String?
    var subtitle: String?
    var coverimage: String?
    var parameter: String?
    var blurbcontent: String?
    enum CodingKeys: String, CodingKey { case title, subtitle, coverimage, parameter, blurbcontent }
}

struct SiteConfig: Codable, Identifiable, Hashable {
    var id: String { key }
    var key: String
    var name: String
    var type: Int?          // 0 xml, 1 json, 3 spider
    var api: String?
    var searchable: Int?
    var quickSearch: Int?
    var ext: String?
    var jar: String?
    var playerType: String?
    var group: String?
    var style: String?
}

struct ParseConfig: Codable, Identifiable, Hashable {
    var id: String { name + (url ?? "") }
    var name: String
    var type: Int?
    var url: String?
    var ext: String?
}

struct Depot: Codable, Identifiable, Hashable {
    var id: String { url }
    var name: String
    var url: String
    var vipverifyswitch: String?
}

struct CollectItem: Codable, Identifiable {
    var id: String { vod_id ?? UUID().uuidString }
    var vod_id: String?
    var vod_name: String?
    var vod_pic: String?
    var cid: String?
}

struct HistoryItem: Codable, Identifiable {
    var id: String { "\(vodId)-\(line)-\(ep)" }
    var vodId: String
    var name: String
    var pic: String?
    var line: Int
    var ep: Int
    var epName: String
    var progress: Double
    var updated: Date
}
