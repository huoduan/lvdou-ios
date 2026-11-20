import SwiftUI

enum Theme {
    static let bg = Color(hex: 0x070A12)
    static let card = Color.white.opacity(0.07)
    static let stroke = Color.white.opacity(0.14)
    static let accent = Color(hex: 0x5B9DFF)
    static let text = Color.white
    static let sub = Color(hex: 0xA7AEBB)
    static let dim = Color(hex: 0x7A8290)
    static let gold = LinearGradient(colors: [Color(hex: 0xFFC24B), Color(hex: 0xFF8A3D)],
                                     startPoint: .leading, endPoint: .trailing)
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

/// 毛玻璃卡片（iOS15+ 用系统材质）
struct GlassCard<Content: View>: View {
    var radius: CGFloat = 20
    var content: () -> Content
    init(radius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.radius = radius; self.content = content
    }
    var body: some View {
        content()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
    }
}

/// 背景渐变（真实环境用模糊海报铺设）
struct AppBackground: View {
    var body: some View {
        ZStack {
            Theme.bg
            RadialGradient(colors: [Color(hex: 0x2C63FF).opacity(0.35), .clear],
                           center: .init(x: 0.1, y: 0.1), startRadius: 0, endRadius: 420)
            RadialGradient(colors: [Color(hex: 0x8B3DFF).opacity(0.28), .clear],
                           center: .init(x: 1.0, y: 0.45), startRadius: 0, endRadius: 400)
            RadialGradient(colors: [Color(hex: 0x00C2B8).opacity(0.18), .clear],
                           center: .init(x: 0.35, y: 0.95), startRadius: 0, endRadius: 420)
        }
        .ignoresSafeArea()
    }
}
