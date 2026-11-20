import Foundation

/// py 源（type=3 爬虫）运行时：内嵌 CPython + PythonKit
/// 脚本契约与 js 源一致：
///   homeVod() -> JSON 字符串 / detailContent(ids) -> JSON / search(wd) -> JSON
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
        if !sys.path.contains(dir) { sys.path.append(dir) }
        module = Python.import(name)
        if let e = Python.exception, !Python.isinstance(e, Python.None) {
            print("[PySpider] import \(name) 失败: \(e)")
            module = nil
        }
    }

    func homeVod() -> String? { call("homeVod") }
    func detailContent(_ ids: String) -> String? { call("detailContent", ids) }
    func search(_ wd: String) -> String? { call("search", wd) }

    private func call(_ fn: String, _ arg: String? = nil) -> String? {
        guard let module else { return nil }
        guard let f = module[dynamicMember: fn] else { return nil }
        let result: PythonObject? = arg.map { f.call(with: $0) } ?? f.call()
        guard let r = result, !Python.isinstance(r, Python.None) else { return nil }
        return String(r)
    }
}
#else
/// 未集成 PythonKit 时的占位实现（编译通过，运行时提示）
final class PySpider {
    init(scriptPath: String) {
        print("[PySpider] 未集成 PythonKit，py 源不可用：\(scriptPath)")
    }
    func homeVod() -> String? { nil }
    func detailContent(_ ids: String) -> String? { nil }
    func search(_ wd: String) -> String? { nil }
}
#endif
