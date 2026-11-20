import Foundation
import CommonCrypto

enum APIError: LocalizedError {
    case badURL, http(Int), decrypt, decode(String), business(String)
    var errorDescription: String? {
        switch self {
        case .badURL: return "地址无效"
        case .http(let c): return "HTTP \(c)"
        case .decrypt: return "数据解密失败"
        case .decode(let m): return "解析失败: \(m)"
        case .business(let m): return m
        }
    }
}

enum AES128 {
    /// 后台格式：ikey(16) + base64(AES-128-CBC(json, key=ikey, iv=ikey))
    static func decrypt(payload: String, key: String) -> Data? {
        guard let data = Data(base64Encoded: payload) else { return nil }
        var out = Data(count: data.count + kCCBlockSizeAES128)
        let outCap = out.count
        var outLen = 0
        let kb = Array(key.utf8), ivb = Array(key.utf8)
        let status = out.withUnsafeMutableBytes { outPtr in
            data.withUnsafeBytes { inPtr in
                CCCrypt(CCOperation(kCCDecrypt), CCAlgorithm(kCCAlgorithmAES128),
                        CCOptions(kCCOptionPKCS7Padding), kb, kb.count, ivb,
                        inPtr.baseAddress, data.count, outPtr.baseAddress, outCap, &outLen)
            }
        }
        guard status == kCCSuccess else { return nil }
        return out.prefix(outLen)
    }
}

final class APIClient {
    static let shared = APIClient()
    let baseURL = AppEnv.baseURL
    let appId = AppEnv.appId
    let apkMark = AppEnv.appMark

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 15
        return URLSession(configuration: c)
    }()

    /// 后台通用调用：自动补 app_id/apk_mark/version/token，自动解密
    @discardableResult
    func call(_ path: String, params: [String: String] = [:]) async throws -> [String: Any] {
        var all = params
        all["app_id"] = appId
        all["apk_mark"] = apkMark
        all["version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        all["time"] = "time"
        all["token"] = LocalStore.token ?? ""

        var req: URLRequest
        if path.hasPrefix("api/users/login") || path.hasPrefix("api/users/register") {
            req = URLRequest(url: baseURL.appendingPathComponent(path))
            req.httpMethod = "POST"
            req.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            req.httpBody = all.map { "\($0.key)=\(Self.escape($0.value))" }.joined(separator: "&").data(using: .utf8)
        } else {
            var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
            comps.queryItems = all.map { URLQueryItem(name: $0.key, value: $0.value) }
            guard let url = comps.url else { throw APIError.badURL }
            req = URLRequest(url: url)
        }

        let (data, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw APIError.http(http.statusCode)
        }
        guard let text = String(data: data, encoding: .utf8) else { throw APIError.decrypt }

        var jsonText = text
        if !text.hasPrefix("{") && text.count > 16 {
            let key = String(text.prefix(16))
            guard let plain = AES128.decrypt(payload: String(text.dropFirst(16)), key: key),
                  let s = String(data: plain, encoding: .utf8) else { throw APIError.decrypt }
            jsonText = s
        }
        guard let obj = try JSONSerialization.jsonObject(with: Data(jsonText.utf8)) as? [String: Any] else {
            throw APIError.decode("非 JSON")
        }
        // 统一业务错误：code != 1 视为失败（FastAdmin 成功为 1）
        if let code = obj["code"] as? Int, code != 1, code != 0, code != 200 {
            throw APIError.business((obj["msg"] as? String) ?? "请求失败(\(code))")
        }
        if let code = obj["code"] as? String, let c = Int(code), c != 1, c != 0, c != 200 {
            throw APIError.business((obj["msg"] as? String) ?? "请求失败(\(c))")
        }
        return obj
    }

    static func escape(_ s: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return s.addingPercentEncoding(withAllowedCharacters: allowed) ?? s
    }
}
