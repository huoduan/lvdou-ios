import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [HistoryItem] = LocalStore.history

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("观看历史").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Button("清空") { LocalStore.history = []; items = [] }.font(.system(size: 12)).foregroundStyle(Theme.dim)
                    Button("关闭") { dismiss() }.font(.system(size: 12)).foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 16).padding(.top, 12)

                if items.isEmpty {
                    Spacer()
                    Text("暂无观看记录").font(.system(size: 13)).foregroundStyle(Theme.dim)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(items) { it in
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(LinearGradient(colors: [Color(hex: 0x2E3A63), Color(hex: 0x4A6FA8)],
                                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 96, height: 54)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(it.name).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                                        Text("看到 \(it.epName) · \(Self.fmt(it.progress))")
                                            .font(.system(size: 10.5)).foregroundStyle(Theme.dim)
                                    }
                                    Spacer()
                                }
                                .padding(10)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(.white.opacity(0.12), lineWidth: 1))
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }

    private static func fmt(_ s: Double) -> String {
        String(format: "%02d:%02d", Int(s) / 60, Int(s) % 60)
    }
}
