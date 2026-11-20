import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @State private var banner = 0
    @State private var showSearch = false
    @State private var showHistory = false
    @State private var chip = 0

    private let chips = ["推荐", "电影", "电视剧", "综艺", "动漫"]

    private var bannerVods: [Vod] { Array((state.sections.first?.vods ?? []).prefix(3)) }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    bannerView
                    chipRow
                    ForEach(state.sections) { section in
                        sectionView(section)
                    }
                    Color.clear.frame(height: 96)
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
            }
            .background(Color.clear)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showSearch) { NavigationView { SearchView().navigationBarHidden(true) }.navigationViewStyle(.stack) }
        .sheet(isPresented: $showHistory) { HistoryView() }
    }

    // 顶部：LOGO 80x28 固定 + 搜索胶囊 + 历史（同一排，位置固定）
    private var header: some View {
        HStack(spacing: 10) {
            LogoSlot(url: state.logoURL)
            Button { showSearch = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("搜索影片、演员").font(.system(size: 12))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Color(hex: 0x8F97A5))
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button { showHistory = true } label: {
                Image(systemName: "clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(hex: 0xE6EBF3))
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.16), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private var bannerView: some View {
        TabView(selection: $banner) {
            ForEach(Array(bannerVods.enumerated()), id: \.offset) { idx, vod in
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(colors: [Color(hex: 0x2B4C86), Color(hex: 0x5F3E8C), Color(hex: 0xB0507E)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("HOT 本周热播").font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(.white.opacity(0.14), in: Capsule())
                        Spacer()
                        Text(vod.vod_name).font(.system(size: 21, weight: .heavy))
                        Text([vod.type_name, vod.vod_year, vod.vod_remarks].compactMap { $0 }.joined(separator: " · "))
                            .font(.system(size: 11.5)).foregroundStyle(Color(hex: 0xE2E7F0))
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1))
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 150)
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 5) {
                ForEach(0..<max(1, bannerVods.count), id: \.self) { i in
                    Capsule()
                        .fill(i == banner ? Color.white : Color.white.opacity(0.45))
                        .frame(width: i == banner ? 16 : 5, height: 5)
                }
            }.padding(12)
        }
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(chips.enumerated()), id: \.offset) { i, c in
                    Button { chip = i } label: {
                        Text(c)
                            .font(.system(size: 11.5, weight: chip == i ? .semibold : .regular))
                            .foregroundStyle(chip == i ? .white : Color(hex: 0xC3CAD6))
                            .padding(.horizontal, 14).frame(height: 30)
                            .background(.ultraThinMaterial, in: Capsule())
                            .overlay(Capsule().strokeBorder(
                                chip == i ? Theme.accent.opacity(0.55) : Color.white.opacity(0.14), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func sectionView(_ section: HomeSection) -> some View {
        VStack(spacing: 10) {
            SectionHeader(title: section.title)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                ForEach(section.vods) { vod in
                    NavigationLink {
                        DetailView(vod: vod)
                    } label: {
                        PosterCard(vod: vod, width: 108)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
