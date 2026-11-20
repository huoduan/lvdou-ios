import Foundation

/// 内嵌 CPython 运行时初始化（需先跑 scripts/bootstrap-python.sh 拉取 Python.xcframework + stdlib）
#if canImport(PythonKit)
import PythonKit

enum PythonRuntime {
    static let isAvailable = true
    private static var initialized = false

    /// 设置 PYTHONHOME/PYTHONPATH 指向 bundle 内的 stdlib，并触发解释器初始化
    static func initialize() {
        guard !initialized else { return }
        let pyVer = "3.11"
        guard let res = Bundle.main.resourcePath else { return }
        let pyHome = res + "/python"
        let lib = pyHome + "/lib/python" + pyVer
        let dynload = lib + "/lib-dynload"
        setenv("PYTHONHOME", pyHome, 1)
        setenv("PYTHONPATH", "\(lib):\(dynload):\(res)", 1)
        _ = Python.import("sys")   // PythonKit 在首次 import 时完成 Py_Initialize
        initialized = true
    }
}
#else
enum PythonRuntime {
    static let isAvailable = false
    static func initialize() {}
}
#endif
