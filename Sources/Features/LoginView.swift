import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @State private var account = ""
    @State private var password = ""
    @State private var isRegister = false
    @State private var busy = false
    @State private var msg = ""

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 14) {
                HStack {
                    Text(isRegister ? "注册" : "登录").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Button("关闭") { dismiss() }.foregroundStyle(Theme.accent)
                }
                Spacer()
                field("账号", text: $account)
                field("密码", text: $password, secure: true)
                if !msg.isEmpty { Text(msg).font(.system(size: 11)).foregroundStyle(Color(hex: 0xFF8A8A)) }

                Button {
                    submit()
                } label: {
                    Text(busy ? "请稍候…" : (isRegister ? "注册并登录" : "登录"))
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity).frame(height: 46)
                        .background(Theme.accent.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(busy)

                Button {
                    isRegister.toggle(); msg = ""
                } label: {
                    Text(isRegister ? "已有账号？去登录" : "没有账号？去注册")
                        .font(.system(size: 12)).foregroundStyle(Theme.sub)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(16)
        }
    }

    private func field(_ p: String, text: Binding<String>, secure: Bool = false) -> some View {
        Group {
            if secure { SecureField(p, text: text) } else { TextField(p, text: text) }
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .foregroundStyle(.white)
        .padding(.horizontal, 14).frame(height: 46)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(.white.opacity(0.16), lineWidth: 1))
    }

    private func submit() {
        guard !account.isEmpty, !password.isEmpty else { msg = "请输入账号和密码"; return }
        busy = true; msg = ""
        Task {
            do {
                if isRegister {
                    try await UserService.register(account: account, password: password)
                    try await UserService.login(account: account, password: password)
                } else {
                    try await UserService.login(account: account, password: password)
                }
                state.user = LocalStore.user
                dismiss()
            } catch {
                msg = error.localizedDescription
            }
            busy = false
        }
    }
}
