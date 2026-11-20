import SwiftUI

struct CardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var card = ""
    @State private var busy = false
    @State private var msg = ""

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 14) {
                HStack {
                    Text("卡密兑换").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Button("关闭") { dismiss() }.foregroundStyle(Theme.accent)
                }
                Spacer()
                Image(systemName: "ticket").font(.system(size: 40)).foregroundStyle(Theme.accent)
                Text("输入卡密，兑换会员时长").font(.system(size: 13)).foregroundStyle(Theme.sub)
                TextField("请输入卡密", text: $card)
                    .textInputAutocapitalization(.none)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).frame(height: 46).frame(maxWidth: 280)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.16), lineWidth: 1))
                if !msg.isEmpty { Text(msg).font(.system(size: 11)).foregroundStyle(Color(hex: 0xFF8A8A)) }
                Button {
                    redeem()
                } label: {
                    Text(busy ? "兑换中…" : "立即兑换")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 280, height: 46)
                        .background(Theme.gold, in: Capsule())
                        .foregroundStyle(Color(hex: 0x2B1600))
                }
                .buttonStyle(.plain)
                .disabled(busy)
                Spacer()
            }
            .padding(16)
        }
    }

    private func redeem() {
        guard !card.isEmpty else { msg = "请输入卡密"; return }
        busy = true; msg = ""
        Task {
            do { msg = try await UserService.redeemCard(card) }
            catch { msg = error.localizedDescription }
            busy = false
        }
    }
}
