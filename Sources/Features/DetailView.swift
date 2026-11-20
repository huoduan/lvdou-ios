import SwiftUI

struct DetailView: View {
    var vod: Vod
    @Environment(\.dismiss) private var dismiss
    @State private var line = 0

    private var lines: [PlayLine] { SiteEngine.lines(from: vod) }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    hero
                    actions
                    if let c = vod.vod_content, !c.isEmpty { desc(c) }
                    lineTabs
                    episodeGrid
                    related
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: 0x2B4C86), Color(hex: 0x5F3E8C), Color(hex: 0xB0507E)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 8) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 34, height: 34)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer()
                Text(vod.vod_name).font(.system(size: 22, weight: .heavy))
                HStack(spacing: 0) {
                    Text(vod.vod_score ?? "").foregroundStyle(Color(hex: 0xFFC85C)).fontWeight(.bold)
                    Text(" 分 · " + [vod.vod_year, vod.vod_area, vod.type_name].compactMap { $0 }.joined(separator: " · "))
                }
                .font(.system(size: 11.5)).foregroundStyle(Color(hex: 0xD5DCE8))
            }
            .padding(16)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(.white.opacity(0.2), lineWidth: 1))
        .padding(.top, 8)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            NavigationLink {
                PlayerView(vod: vod, lines: lines, lineIndex: line, episodeIndex: 0)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("立即播放").font(.system(size: 14, weight: .bold))
                }
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(Theme.accent.opacity(0.9), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {} label: {
                HStack(spacing: 6) {
                    Image(systemName: "star"); Text("收藏")
                }
                .font(.system(size: 13, weight: .medium))
                .frame(width: 100, height: 46)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)
    }

    private func desc(_ text: String) -> some View {
        Text(text).font(.system(size: 11)).foregroundStyle(Theme.sub)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1))
    }

    private var lineTabs: some View {
        HStack(spacing: 0) {
            ForEach(Array(lines.enumerated()), id: \.offset) { i, l in
                Button { line = i } label: {
                    Text(l.name)
                        .font(.system(size: 13, weight: line == i ? .bold : .regular))
                        .foregroundStyle(line == i ? .white : Color(hex: 0x9AA2AF))
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .overlay(alignment: .bottom) {
                            if line == i {
                                Capsule().fill(Theme.accent).frame(width: 34, height: 3)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(.white.opacity(0.14), lineWidth: 1))
    }

    private var episodeGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
            ForEach(Array((lines[safe: line]?.episodes ?? []).enumerated()), id: \.offset) { i, ep in
                NavigationLink {
                    PlayerView(vod: vod, lines: lines, lineIndex: line, episodeIndex: i)
                } label: {
                    Text(ep.name.isEmpty ? "第\(i + 1)集" : ep.name)
                        .font(.system(size: 11.5, weight: i == 0 ? .semibold : .regular))
                        .foregroundStyle(i == 0 ? Color(hex: 0xDCE7FF) : Color(hex: 0xC7CDD8))
                        .frame(maxWidth: .infinity).frame(height: 34)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(i == 0 ? Theme.accent.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var related: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("相关推荐").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
            ForEach(Array((state0().first?.vods ?? []).prefix(3))) { v in
                NavigationLink { DetailView(vod: v) } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(LinearGradient(colors: [Color(hex: 0x1F5E56), Color(hex: 0x3E8E7E)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 86, height: 48)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(v.vod_name).font(.system(size: 12.5, weight: .semibold))
                            Text(v.type_name ?? "剧情").font(.system(size: 10.5)).foregroundStyle(Theme.dim)
                        }
                        Spacer()
                    }
                    .foregroundStyle(Color(hex: 0xDDE3EC))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func state0() -> [HomeSection] { DemoData.sections }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}
