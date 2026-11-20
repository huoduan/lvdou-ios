import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @State private var showAbout = false
    @State private var cleared = false

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("设置").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Button("关闭") { dismiss() }.foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 16).padding(.top, 12)

                ScrollView {
                    VStack(spacing: 8) {
                        if !state.isLogin {
                            NavigationLink { LoginView() } label: {
                                row("登录 / 注册", detail: "未登录", accent: true)
                            }.buttonStyle(.plain)
                        } else {
                            Button { UserService.logout(); state.user = nil } label: {
                                row("退出登录", detail: state.user?.username ?? "", accent: true)
                            }.buttonStyle(.plain)
                        }

                        Button {
                            URLCache.shared.removeAllCachedResponses()
                            cleared = true
                        } label: {
                            row("清除缓存", detail: cleared ? "已清理" : "128.6 MB")
                        }.buttonStyle(.plain)

                        NavigationLink { AboutView() } label: {
                            row("关于")
                        }.buttonStyle(.plain)
                    }
                    .padding(16)
                }
            }
        }
    }

    private func row(_ t: String, detail: String = "", accent: Bool = false) -> some View {
        HStack {
            Text(t).font(.system(size: 12.5)).foregroundStyle(accent ? Theme.accent : Color(hex: 0xC7CDD8))
            Spacer()
            Text(detail).font(.system(size: 11.5)).foregroundStyle(Theme.dim)
            Text("›").foregroundStyle(Theme.dim)
        }
        .padding(.horizontal, 14).frame(height: 46)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(.white.opacity(0.10), lineWidth: 1))
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 12) {
                Spacer()
                Text("绿豆影视").font(.system(size: 22, weight: .heavy)).foregroundStyle(.white)
                Text("iPhone 版 · v1.0.0 (1)").font(.system(size: 12)).foregroundStyle(Theme.dim)
                Text("本应用仅供个人学习交流使用").font(.system(size: 10)).foregroundStyle(Theme.dim)
                Spacer()
            }
        }
        .navigationTitle("关于")
    }
}
