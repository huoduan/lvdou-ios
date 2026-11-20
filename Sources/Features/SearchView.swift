import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var state: AppState
    @State private var text = ""
    @State private var results: [Vod] = []
    @State private var hint = ""

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Theme.dim)
                        TextField("搜索影片、演员", text: $text)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.search)
                            .onSubmit(run)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14).frame(height: 40)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.16), lineWidth: 1))

                    Button("取消") { dismiss() }.foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 16)

                if !hint.isEmpty {
                    Text(hint).font(.system(size: 11)).foregroundStyle(Theme.dim).padding(.top, 4)
                }

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                        ForEach(results) { v in
                            NavigationLink { DetailView(vod: v) } label: { PosterCard(vod: v, width: 108) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .padding(.top, 8)
        }
    }

    private func run() {
        guard !text.isEmpty else { return }
        Task {
            if let site = state.sites.first, site.type == 1 {
                do {
                    results = try await SiteEngine.search(site: site, kw: text)
                    hint = "在「\(site.name)」找到 \(results.count) 条"
                    return
                } catch {}
            }
            let all = DemoData.sections.flatMap(\.vods)
            results = all.filter { $0.vod_name.contains(text) }
            hint = results.isEmpty ? "暂无结果（示例数据）" : "示例数据结果"
        }
    }
}
