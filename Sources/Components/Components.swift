import SwiftUI

/// LOGO 固定槽位：80x28，等比完整显示，未配置则留空
struct LogoSlot: View {
    var url: URL?
    var body: some View {
        ZStack {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFit()
                    default:
                        Color.clear
                    }
                }
            }
        }
        .frame(width: 80, height: 28)
    }
}

/// 底部悬浮 Dock
enum DockTab: Int, CaseIterable {
    case home, live, mine
    var title: String { ["首页", "直播", "我的"][rawValue] }
    var symbol: String { ["house.fill", "tv.fill", "person.fill"][rawValue] }
}

struct DockBar: View {
    @Binding var selection: DockTab
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DockTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { selection = tab }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 18, weight: .medium))
                        Text(tab.title).font(.system(size: 9.5, weight: .medium))
                    }
                    .foregroundStyle(selection == tab ? Theme.accent : Color(hex: 0x8F97A5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Theme.accent.opacity(0.18))
                                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Theme.accent.opacity(0.45), lineWidth: 1))
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
        .padding(.horizontal, 26)
        .padding(.bottom, 6)
    }
}

/// 海报卡片
struct PosterCard: View {
    var vod: Vod
    var width: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x3B4C7A), Color(hex: 0x8C4C7B)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                if let u = vod.picURL {
                    AsyncImage(url: u) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { Color.clear }
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Text(vod.vod_name)
                        .font(.system(size: 14, weight: .heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(8)
                }
                if let r = vod.vod_remarks, !r.isEmpty {
                    Text(r).font(.system(size: 9, weight: .semibold))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.black.opacity(0.45), in: Capsule())
                        .foregroundStyle(Color(hex: 0xEAF0FA))
                        .padding(6)
                }
            }
            .frame(width: width, height: width * 1.23)
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
            Text(vod.vod_name)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(Color(hex: 0xDDE3EC))
                .lineLimit(1)
        }
        .frame(width: width, alignment: .leading)
    }
}

struct SectionHeader: View {
    var title: String
    var body: some View {
        HStack {
            Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
            Spacer()
            Text("更多 ›").font(.system(size: 11)).foregroundStyle(Color(hex: 0x8F97A5))
        }
    }
}
