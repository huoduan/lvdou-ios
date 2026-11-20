import Foundation
import JavaScriptCore
import CryptoKit

/// js 源（type=3, jar/js 爬虫）运行时：用 JavaScriptCore 执行 TVBox 风格爬虫脚本
/// 对外暴露 req / log / base64 / md5 等常用函数，脚本里通过 homeVod/detailContent/search 返回 JSON 字符串
final class JSSpider {
    private let ctx = JSContext()

    init(script: String) {
        ctx?.exceptionHandler = { _, e in print("[JS] \(e?.toString() ?? "err")") }
        registerBuiltins()
        ctx?.evaluateScript(script)
    }

    private func registerBuiltins() {
        let req: @convention(block) (String, [String: Any]?) -> String = { url, opts in
            Self.syncRequest(url: url, opts: opts)
        }
        ctx?.setObject(req, forKeyedSubscript: "req" as NSString)

        let log: @convention(block) (String) -> Void = { print("[JS-log] \($0)") }
        ctx?.setObject(log, forKeyedSubscript: "log" as NSString)

        let b64e: @convention(block) (String) -> String = { Data($0.utf8).base64EncodedString() }
        let b64d: @convention(block) (String) -> String = {
            guard let d = Data(base64Encoded: $0) else { return "" }
            return String(data: d, encoding: .utf8) ?? ""
        }
        ctx?.setObject(b64e, forKeyedSubscript: "base64Encode" as NSString)
        ctx?.setObject(b64d, forKeyedSubscript: "base64Decode" as NSString)

        let md5: @convention(block) (String) -> String = {
            Insecure.MD5.hash(data: Data($0.utf8)).map { String(format: "%02x", $0) }.joined()
        }
        ctx?.setObject(md5, forKeyedSubscript: "md5" as NSString)
    }

    /// 调用脚本内函数并取返回的字符串（通常是 JSON）
    func call(_ fn: String, args: [String] = []) -> String? {
        let jsFn = ctx?.objectForKeyedSubscript(fn)
        return jsFn?.call(withArguments: args)?.toString()
    }

    func homeVod() -> String? { call("homeVod") }
    func detailContent(_ ids: String) -> String? { call("detailContent", args: [ids]) }
    func search(_ wd: String) -> String? { call("search", args: [wd]) }

    /// 同步网络桥接（供 JS 内 req 使用）
    private static func syncRequest(url: String, opts: [String: Any]?) -> String {
        guard let u = URL(string: url) else { return "" }
        var req = URLRequest(url: u)
        req.timeoutInterval = 15
        if let method = opts?["method"] as? String { req.httpMethod = method }
        if let body = opts?["body"] as? String { req.httpBody = body.data(using: .utf8) }
        if let headers = opts?["headers"] as? [String: String] {
            headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        }
        let sem = DispatchSemaphore(value: 0)
        var result = ""
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data { result = String(data: data, encoding: .utf8) ?? "" }
            sem.signal()
        }.resume()
        _ = sem.wait(timeout: .now() + 16)
        return result
    }
}
