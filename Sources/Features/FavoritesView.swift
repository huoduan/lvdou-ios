import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [Vod] = LocalStore.favorites

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("我的收藏").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                    Spacer()
                    Button("关闭") { dismiss() }.foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 16).padding(.top, 12)

                if items.isEmpty {
                    Spacer()
                    Text("还没有收藏").font(.system(size: 13)).foregroundStyle(Theme.dim)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                            ForEach(items) { v in
                                NavigationLink { DetailView(vod: v) } label: { PosterCard(vod: v, width: 108) }
                                    .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .onAppear {
            Task { if let remote = try? await UserService.favorites(), !remote.isEmpty { items = remote } }
        }
    }
}
