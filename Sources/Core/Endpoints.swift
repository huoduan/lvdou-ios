import Foundation

enum EP {
    static let initMain   = "api/main/init"
    static let login      = "api/users/login"
    static let register   = "api/users/register"
    static let logout     = "api/users/logout"
    static let userIndex  = "api/users/index"
    static let signCheck  = "api/Sign/isSign"
    static let signIn     = "api/Sign/init"
    static let card       = "api/Card/index"
    static let collectAdd = "api/Collect/addCollect"
    static let collectList = "api/Collect/getCollect"
    static let collectDel = "api/Collect/deleteCollect"
    static let invite     = "api/invite/index"
    static let groups     = "api/group/index"
    static let hots       = "api/hots/init"
    static let store      = "api/index/store"
    static let live       = "api/index/live"
}
