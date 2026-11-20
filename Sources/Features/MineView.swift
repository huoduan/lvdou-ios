import SwiftUI

struct MineView: View {
    @EnvironmentObject var state: AppState
    @State private var showHistory = false
    @State private var showFavorites = false
    @State private var showCard = false
    @State private var showLogin = false
    @State private var showSettings = false

    private let items: [(String, String)] = [
        ("clock", "观看历史"), ("star", "我的收藏"), ("ticket", "卡密兑换"), ("person.badge.plus", "邀请好友"),
        ("airplayvideo", "投屏"), ("gearshape", "播放设置"), ("bubble.left", "联系客服"), ("info.circle", "关于")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                profile
                vipCard
                grid
                rows
                Color.clear.frame(height: 96)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .sheet(isPresented: $showHistory) { HistoryView() }
        .sheet(isPresented: $showFavorites) { NavigationView { FavoritesView().navigationBarHidden(true) }.navigationViewStyle(.stack) }
        .sheet(isPresented: $showCard) { CardView() }
        .sheet(isPresented: $showLogin) { LoginView() }
        .sheet(isPresented: $showSettings) { NavigationView { SettingsView().navigationBarHidden(true) }.navigationViewStyle(.stack) }
    }

    private var profile: some View {
        Button { state.isLogin ? showSettings = true : (showLogin = true) } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [Color(hex: 0x2B4C86), Color(hex: 0x8B3DFF)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text(String((state.user?.username ?? "绿").prefix(1)))
                        .font(.system(size: 19, weight: .heavy)).foregroundStyle(.white)
                }
                .frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: 6) {
                    Text(state.user?.username ?? "点击登录")
                        .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    Text(state.isLogin ? "VIP 年卡 · 剩余 328 天" : "登录后同步收藏、卡密、签到")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(Color(hex: 0x2B1600))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(state.isLogin ? Theme.gold : Color.white.opacity(0.12), in: Capsule())
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Theme.dim)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var vipCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("开通 / 续费会员").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                Text("解锁 4K 画质 · 无广告 · 多设备").font(.system(size: 11)).foregroundStyle(Theme.sub)
            }
            Spacer()
            Text("立即开通")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(Color(hex: 0x2B1600))
                .padding(.horizontal, 16).frame(height: 34)
                .background(Theme.gold, in: Capsule())
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(.white.opacity(0.16), lineWidth: 1))
    }

    private var grid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 14) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, it in
                Button { tap(i) } label: {
                    VStack(spacing: 8) {
                        Image(systemName: it.0)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color(hex: 0xC7CCD4))
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        Text(it.1).font(.system(size: 10.5)).foregroundStyle(Color(hex: 0xB9C0CC))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(.white.opacity(0.14), lineWidth: 1))
    }

    private var rows: some View {
        VStack(spacing: 8) {
            row("清除缓存", detail: "128.6 MB") {
                URLCache.shared.removeAllCachedResponses()
            }
            row("检查更新", detail: "v1.0.0") {}
            row("账号与安全", detail: "") { showSettings = true }
        }
    }

    private func row(_ t: String, detail: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(t).font(.system(size: 12.5)).foregroundStyle(Color(hex: 0xC7CDD8))
                Spacer()
                Text(detail).font(.system(size: 11.5)).foregroundStyle(Theme.dim)
                Text("›").foregroundStyle(Theme.dim)
            }
            .padding(.horizontal, 14).frame(height: 46)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func tap(_ i: Int) {
        switch i {
        case 0: showHistory = true
        case 1: state.isLogin ? (showFavorites = true) : (showLogin = true)
        case 2: showCard = true
        case 5: showSettings = true
        default: break
        }
    }
}
