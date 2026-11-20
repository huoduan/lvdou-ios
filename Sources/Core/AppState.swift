import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var config: AppConfig?
    @Published var sections: [HomeSection] = []
    @Published var banners: [BannerConfig] = []
    @Published var depots: [Depot] = []
    @Published var sites: [SiteConfig] = []
    @Published var parses: [ParseConfig] = []
    @Published var loading = false
    @Published var errorText: String?
    @Published var user: UserInfo? { didSet { LocalStore.user = user } }

    var isLogin: Bool { !(user?.token?.isEmpty ?? true) || LocalStore.token != nil }

    var logoURL: URL? {
        guard var s = config?.logoimage, !s.isEmpty else { return nil }
        if s.hasPrefix("http") { return URL(string: s) }
        if !s.hasPrefix("/") { s = "/" + s }
        return AppEnv.baseURL.appendingPathComponent(s)
    }

    func load() async {
        loading = true; defer { loading = false }
        user = LocalStore.user
        do {
            let obj = try await APIClient.shared.call(EP.initMain)
            let data = (obj["data"] as? [String: Any]) ?? obj
            if let site = data["siteConfig"] as? [String: Any],
               let appCfg = site["app_config"] as? [String: Any] {
                config = try JSONDecoder().decode(AppConfig.self, from: JSONSerialization.data(withJSONObject: appCfg))
            }
            sections = Self.parseHome(data["homeConfig"])
            banners = Self.decode([BannerConfig].self, data["homeConfig"])
            depots = Self.decode([Depot].self, data["depotConfig"])
            parses = Self.decode([ParseConfig].self, data["parsesConfig"])
            if sections.isEmpty { sections = DemoData.sections }
            errorText = nil
            await loadRepos()
        } catch {
            sections = DemoData.sections
            errorText = "接口不可用，已显示示例数据"
        }
    }

    /// 拉取仓库，得到站点列表（json / 分隔文本两种常见格式）
    func loadRepos() async {
        var out: [SiteConfig] = []
        for depot in depots {
            if let s = try? await Engine.fetchRepo(depot.url) { out.append(contentsOf: s) }
        }
        if !out.isEmpty { sites = out }
    }

    static func parseHome(_ raw: Any?) -> [HomeSection] {
        guard let list = raw as? [[String: Any]] else { return [] }
        var out: [HomeSection] = []
        for item in list {
            let title = (item["name"] as? String) ?? (item["title"] as? String) ?? "推荐"
            let vodRaw = (item["vod"] as? [[String: Any]])
                ?? (item["list"] as? [[String: Any]])
                ?? (item["data"] as? [[String: Any]]) ?? []
            let vods: [Vod] = vodRaw.compactMap { d in
                guard let id = (d["vod_id"] as? String) ?? (d["id"].map { "\($0)" }) else { return nil }
                return Vod(vod_id: id,
                           vod_name: (d["vod_name"] as? String) ?? (d["name"] as? String) ?? "",
                           vod_pic: d["vod_pic"] as? String,
                           vod_remarks: d["vod_remarks"] as? String,
                           vod_year: d["vod_year"] as? String,
                           vod_area: d["vod_area"] as? String,
                           vod_score: d["vod_score"] as? String,
                           vod_content: d["vod_content"] as? String,
                           vod_play_from: d["vod_play_from"] as? String,
                           vod_play_url: d["vod_play_url"] as? String,
                           type_name: d["type_name"] as? String)
            }
            if !vods.isEmpty { out.append(HomeSection(title: title, vods: vods)) }
        }
        return out
    }

    static func decode<T: Decodable>(_ t: T.Type, _ raw: Any?) -> [T] {
        guard let arr = raw as? [Any] else { return [] }
        return arr.compactMap { item in
            guard let dict = item as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
            return try? JSONDecoder().decode(T.self, from: data)
        }
    }
}

enum DemoData {
    static let sections: [HomeSection] = [
        HomeSection(title: "热门推荐", vods: [
            Vod(vod_id: "1", vod_name: "长安十二时辰", vod_pic: nil, vod_remarks: "全48集", vod_year: "2019", vod_area: "大陆", vod_score: "8.3", vod_content: "上元节前夕，长安城陷入死局，死囚张小敬与少年李必携手，在十二时辰内找出突厥狼卫，拯救长安。", vod_play_from: "线路一", vod_play_url: "第1集$http://example.com/1.m3u8#第2集$http://example.com/2.m3u8", type_name: "古装"),
            Vod(vod_id: "2", vod_name: "繁花", vod_remarks: "全30集", vod_score: "8.7", type_name: "剧情"),
            Vod(vod_id: "3", vod_name: "流浪地球3", vod_remarks: "HD", vod_score: "8.0", type_name: "科幻"),
            Vod(vod_id: "4", vod_name: "三体", vod_remarks: "更新至18", vod_score: "8.7", type_name: "科幻"),
            Vod(vod_id: "5", vod_name: "庆余年2", vod_remarks: "全36集", vod_score: "7.9", type_name: "古装"),
            Vod(vod_id: "6", vod_name: "狂飙", vod_remarks: "全39集", vod_score: "8.5", type_name: "犯罪")
        ]),
        HomeSection(title: "电影", vods: [
            Vod(vod_id: "7", vod_name: "流浪地球3", vod_remarks: "HD", type_name: "科幻"),
            Vod(vod_id: "8", vod_name: "满江红", vod_remarks: "HD", type_name: "剧情")
        ])
    ]
}
