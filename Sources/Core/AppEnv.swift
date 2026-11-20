import Foundation

/// 后台对接配置 —— 与安卓端 App.java 的 getAppInfo() 保持一致
/// 改域名 / 换应用，只需要改这一个文件里的字段
enum AppEnv {
    /// 后台域名（安卓: app_api 的 base64 解码值，如 http://tt.lvdoui.net）
    static let baseURL = URL(string: "http://tt.lvdoui.net")!

    /// 应用 ID（安卓: app_id 去掉 "demo" 后缀，如 "10000demo" → "10000"）
    static let appId = "10000"

    /// 应用标识（安卓: app_mark，如 "lvdou-box-ui-6"）
    static let appMark = "lvdou-box-ui-6"

    /// 应用密钥（安卓: app_key，如 "7E3EFC55E756869192D127584FF280C5"）
    /// 后台仅在请求带 sign 时才校验，当前客户端不带 sign，故仅为记录用途
    static let appKey = "7E3EFC55E756869192D127584FF280C5"
}
