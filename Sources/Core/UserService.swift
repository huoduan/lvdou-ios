import Foundation

/// 用户相关接口封装（登录/注册/签到/卡密/收藏/邀请/会员组）
enum UserService {
    static func login(account: String, password: String) async throws -> UserInfo {
        let obj = try await APIClient.shared.call(EP.login, params: ["account": account, "password": password])
        let data = (obj["data"] as? [String: Any]) ?? obj
        guard let ui = data["userinfo"] as? [String: Any] else { throw APIError.decode("无用户信息") }
        let user = try decode(UserInfo.self, from: ui)
        LocalStore.token = user.token
        LocalStore.user = user
        return user
    }

    static func register(account: String, password: String, nickname: String? = nil) async throws {
        var p = ["account": account, "password": password]
        if let nickname { p["nickname"] = nickname }
        _ = try await APIClient.shared.call(EP.register, params: p)
    }

    static func logout() {
        LocalStore.token = nil
        LocalStore.user = nil
        Task { try? await APIClient.shared.call(EP.logout) }
    }

    static func userIndex() async throws -> UserInfo {
        let obj = try await APIClient.shared.call(EP.userIndex)
        let data = (obj["data"] as? [String: Any]) ?? obj
        let user = try decode(UserInfo.self, from: data)
        LocalStore.user = user
        return user
    }

    static func signCheck() async throws -> Bool {
        let obj = try await APIClient.shared.call(EP.signCheck)
        return ((obj["data"] as? [String: Any])?["isSign"] as? Int) == 1
    }

    static func signIn() async throws -> String {
        let obj = try await APIClient.shared.call(EP.signIn)
        return (obj["msg"] as? String) ?? "签到成功"
    }

    static func redeemCard(_ card: String) async throws -> String {
        let obj = try await APIClient.shared.call(EP.card, params: ["card": card])
        return (obj["msg"] as? String) ?? "兑换成功"
    }

    static func inviteCount() async throws -> Int {
        let obj = try await APIClient.shared.call(EP.invite)
        return ((obj["data"] as? [String: Any])?["inviteCount"] as? Int) ?? 0
    }

    static func favorites() async throws -> [Vod] {
        let obj = try await APIClient.shared.call(EP.collectList)
        return parseVods((obj["data"] as? [String: Any])?["list"])
    }

    static func addFavorite(_ vod: Vod) async throws {
        _ = try await APIClient.shared.call(EP.collectAdd, params: [
            "vod_id": vod.vod_id, "name": vod.vod_name, "pic": vod.vod_pic ?? ""
        ])
    }

    static func deleteFavorite(_ vod: Vod) async throws {
        _ = try await APIClient.shared.call(EP.collectDel, params: ["vod_id": vod.vod_id])
    }

    private static func parseVods(_ raw: Any?) -> [Vod] {
        guard let list = raw as? [[String: Any]] else { return [] }
        return list.compactMap { d in
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
    }

    private static func decode<T: Decodable>(_ t: T.Type, from any: [String: Any]) throws -> T {
        try JSONDecoder().decode(t, from: JSONSerialization.data(withJSONObject: any))
    }
}
