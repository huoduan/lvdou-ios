import Foundation

/// 内容引擎：苹果CMS JSON 接口（type=1）原生解析 + 解析接口（解析地址）
/// 站点 type：0 xml / 1 json / 3 spider（js|py），这里原生支持 1，spider 交给 SpiderRuntime
enum SiteEngine {

    /// 追加查询参数（api 可能已带 query）
    static func buildURL(_ api: String, _ query: [URLQueryItem]) -> URL? {
        guard var comps = URLComponents(string: api) else { return nil }
        var items = comps.queryItems ?? []
        items.append(contentsOf: query)
        comps.queryItems = items
        return comps.url
    }

    static func homeVod(site: SiteConfig, page: Int = 1) async throws -> [Vod] {
        guard let api = site.api, let u = buildURL(api, [.init(name: "ac", value: "videolist"),
                                                         .init(name: "pg", value: "\(page)")]) else {
            throw APIError.badURL
        }
        return try await fetchVods(u)
    }

    static func detail(site: SiteConfig, ids: String) async throws -> [Vod] {
        guard let api = site.api, let u = buildURL(api, [.init(name: "ac", value: "videolist"),
                                                         .init(name: "ids", value: ids)]) else {
            throw APIError.badURL
        }
        return try await fetchVods(u)
    }

    static func search(site: SiteConfig, kw: String, page: Int = 1) async throws -> [Vod] {
        guard let api = site.api, let u = buildURL(api, [.init(name: "ac", value: "videolist"),
                                                         .init(name: "wd", value: kw),
                                                         .init(name: "pg", value: "\(page)")]) else {
            throw APIError.badURL
        }
        return try await fetchVods(u)
    }

    /// 苹果CMS 标准返回：{ code:1, list:[{vod_id,vod_name,...}] }
    static func fetchVods(_ url: URL) async throws -> [Vod] {
        var req = URLRequest(url: url)
        req.timeoutInterval = 15
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.decode("站点返回非 JSON")
        }
        let list = (obj["list"] as? [[String: Any]]) ?? (obj["data"] as? [[String: Any]]) ?? []
        return list.compactMap { d in
            guard let id = (d["vod_id"] as? String) ?? (d["vod_id"] as? Int).map(String.init) else { return nil }
            return Vod(vod_id: id,
                       vod_name: (d["vod_name"] as? String) ?? "",
                       vod_pic: d["vod_pic"] as? String,
                       vod_remarks: d["vod_remarks"] as? String,
                       vod_year: d["vod_year"] as? String,
                       vod_area: d["vod_area"] as? String,
                       vod_score: d["vod_score"] as? String,
                       vod_content: (d["vod_content"] as? String) ?? (d["vod_blurb"] as? String),
                       vod_play_from: d["vod_play_from"] as? String,
                       vod_play_url: d["vod_play_url"] as? String,
                       type_name: (d["type_name"] as? String) ?? (d["type_name_1"] as? String))
        }
    }

    /// 把 play_from / play_url 拆成线路 + 集数
    static func lines(from vod: Vod) -> [PlayLine] {
        guard let from = vod.vod_play_from, let url = vod.vod_play_url else {
            return [PlayLine(name: "线路一", episodes: [])]
        }
        let names = from.components(separatedBy: "$$$")
        let groups = url.components(separatedBy: "$$$")
        return zip(names, groups).map { n, g in
            PlayLine(name: n, episodes: g.components(separatedBy: "#").compactMap { item in
                let p = item.components(separatedBy: "$")
                guard p.count >= 2 else { return nil }
                return Episode(name: p[0], url: p[1])
            })
        }
    }
}

/// 解析（jiexi）地址解析：把播放地址交给解析接口，换出可直接播的 m3u8/mp4
enum ParseResolver {
    static func resolve(_ parse: ParseConfig, playURL: String) async throws -> String {
        guard var api = parse.url, !api.isEmpty else { return playURL }
        let target = playURL
        // 多数解析接口约定：接口 + ?url= 编码后的播放地址
        if !api.contains("?") { api += "?" } else if !api.hasSuffix("&") && !api.hasSuffix("?") { api += "&" }
        let full = api + "url=" + (target.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? target)
        guard let u = URL(string: full) else { return playURL }

        var req = URLRequest(url: u)
        req.timeoutInterval = 20
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await URLSession.shared.data(for: req)

        // JSON 解析接口：{ url: "..." }
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let u2 = obj["url"] as? String, !u2.isEmpty { return u2 }

        // 纯文本解析接口：直接返回播放地址
        if let text = String(data: data, encoding: .utf8),
           text.contains(".m3u8") || text.contains(".mp4") {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // 兜底：如果原始地址本身就能播，直接返回
        if playURL.contains(".m3u8") || playURL.contains(".mp4") || playURL.hasPrefix("http") {
            return playURL
        }
        _ = resp
        return playURL
    }
}

extension Engine {
    /// 拉取仓库内容，返回站点列表（支持 JSON 数组 / {"sites":[...]} / 分隔文本）
    static func fetchRepo(_ url: String) async throws -> [SiteConfig] {
        guard let u = URL(string: url) else { throw APIError.badURL }
        var req = URLRequest(url: u); req.timeoutInterval = 15
        let (data, _) = try await URLSession.shared.data(for: req)

        // 1) JSON
        if let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return mapSites(arr)
        }
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            for k in ["sites", "list", "data"] {
                if let arr = obj[k] as? [[String: Any]], !arr.isEmpty { return mapSites(arr) }
            }
        }
        // 2) 文本：每行一条，$ 或 , 分隔
        guard let text = String(data: data, encoding: .utf8) else { return [] }
        return text.components(separatedBy: .newlines).compactMap { line in
            let parts = line.contains("$") ? line.components(separatedBy: "$")
                                           : line.components(separatedBy: ",")
            guard parts.count >= 2, !parts[0].isEmpty else { return nil }
            return SiteConfig(key: parts[0], name: parts[1],
                              type: parts.count > 2 ? Int(parts[2]) : 1,
                              api: parts.count > 3 ? parts[3] : nil,
                              searchable: nil, quickSearch: nil, ext: nil, jar: nil,
                              playerType: nil, group: nil, style: nil)
        }
    }

    private static func mapSites(_ arr: [[String: Any]]) -> [SiteConfig] {
        arr.compactMap { d in
            guard let key = (d["key"] as? String) ?? (d["name"] as? String) else { return nil }
            return SiteConfig(key: key,
                              name: (d["name"] as? String) ?? key,
                              type: (d["type"] as? Int) ?? ((d["type"] as? String).flatMap(Int.init)) ?? 1,
                              api: d["api"] as? String,
                              searchable: (d["searchable"] as? Int) ?? ((d["searchable"] as? String).flatMap(Int.init)),
                              quickSearch: (d["quickSearch"] as? Int) ?? ((d["quickSearch"] as? String).flatMap(Int.init)),
                              ext: d["ext"] as? String,
                              jar: d["jar"] as? String,
                              playerType: (d["playerType"] as? String) ?? (d["playerType"] as? Int).map(String.init),
                              group: d["group"] as? String,
                              style: (d["style"] as? String) ?? (d["style"] as? Int).map(String.init))
        }
    }
}
