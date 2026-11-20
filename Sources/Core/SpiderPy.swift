import Foundation

/// py 源（type=3 爬虫）运行时：内嵌 CPython + PythonKit
/// 脚本契约：homeVod() / detailContent(ids) / search(wd) 均返回 JSON 字符串
#if canImport(PythonKit)
import PythonKit

final class PySpider {
    private var module: PythonObject?

    init(scriptPath: String) {
        PythonRuntime.initialize()
        let file = URL(fileURLWithPath: scriptPath)
        let dir = file.deletingLastPathComponent().path
        let name = file.deletingPathExtension().lastPathComponent

        let sys = Python.import("sys")
        sys.path.append(dir)
        module = Python.import(name)
    }

    func homeVod() -> String? { call("homeVod", nil) }
    func detailContent(_ ids: String) -> String? { call("detailContent", ids) }
    func search(_ wd: String) -> String? { call("search", wd) }

    private func call(_ fn: String, _ arg: String?) -> String? {
        guard let module = module else { return nil }
        let f = module[dynamicMember: fn]
        let result: PythonObject
        if let arg = arg {
            result = f.call(arg)
        } else {
            result = f.call()
        }
        let text = String(result)
        return text == "None" ? nil : text
    }
}
#else
final class PySpider {
    init(scriptPath: String) {
        print("[PySpider] 未集成 PythonKit，py 源不可用：\(scriptPath)")
    }
    func homeVod() -> String? { nil }
    func detailContent(_ ids: String) -> String? { nil }
    func search(_ wd: String) -> String? { nil }
}
#endif
