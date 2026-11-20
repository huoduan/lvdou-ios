import SwiftUI
import AVKit

struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer
    func makeUIView(context: Context) -> PlayerUIView {
        let v = PlayerUIView()
        v.playerLayer.player = player
        return v
    }
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

final class PlayerUIView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct PlayerView: View {
    @EnvironmentObject var state: AppState
    var vod: Vod
    var lines: [PlayLine]
    var lineIndex: Int
    var episodeIndex: Int

    @State private var current = 0
    @State private var player = AVPlayer()
    @State private var isPlaying = false
    @State private var time: Double = 0
    @State private var duration: Double = 0
    @State private var showControls = true
    @State private var timer: Any?

    private var episodes: [Episode] { lines[safe: lineIndex]?.episodes ?? [] }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    videoArea
                    Text("\(vod.vod_name) · \(episodes[safe: current]?.name ?? "第1集")")
                        .font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    episodeStrip
                    related
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
        .onAppear { current = episodeIndex; load() }
        .onDisappear { player.pause() }
    }

    private var videoArea: some View {
        ZStack {
            Color.black
            PlayerLayerView(player: player)
            LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .center, endPoint: .bottom)
            if !isPlaying {
                Button { toggle() } label: {
                    Image(systemName: "play.fill").font(.system(size: 26))
                        .foregroundStyle(.white)
                        .frame(width: 62, height: 62)
                        .background(.white.opacity(0.16), in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            VStack {
                Spacer()
                VStack(spacing: 8) {
                    Slider(value: Binding(get: { time }, set: { seek($0) }), in: 0...max(duration, 1))
                        .tint(Theme.accent)
                    HStack {
                        Text(fmt(time) + " / " + fmt(duration))
                            .font(.system(size: 10)).foregroundStyle(Color(hex: 0xDCE3EE))
                        Spacer()
                        Text("1080P  全屏").font(.system(size: 10)).foregroundStyle(Color(hex: 0xDCE3EE))
                    }
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1))
                .padding(10)
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
            .strokeBorder(.white.opacity(0.16), lineWidth: 1))
        .padding(.top, 8)
    }

    private var episodeStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 18) {
                Text("选集").font(.system(size: 12.5, weight: .bold)).foregroundStyle(.white)
                Text("简介").font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x9AA2AF))
                Text("相关").font(.system(size: 12.5)).foregroundStyle(Color(hex: 0x9AA2AF))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(Array(episodes.enumerated()), id: \.offset) { i, ep in
                    Button { current = i; load() } label: {
                        Text(ep.name.isEmpty ? "\(i + 1)" : ep.name)
                            .font(.system(size: 11.5, weight: i == current ? .semibold : .regular))
                            .foregroundStyle(i == current ? Color(hex: 0xDCE7FF) : Color(hex: 0xC7CDD8))
                            .frame(maxWidth: .infinity).frame(height: 34)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(i == current ? Theme.accent.opacity(0.5) : Color.white.opacity(0.12), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var related: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("相关推荐").font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
            ForEach(Array((DemoData.sections.first?.vods ?? []).prefix(3))) { v in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(LinearGradient(colors: [Color(hex: 0x6C3B2E), Color(hex: 0xC06A3E)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(v.vod_name).font(.system(size: 12.5, weight: .semibold))
                        Text(v.vod_remarks ?? "").font(.system(size: 10.5)).foregroundStyle(Theme.dim)
                    }
                    Spacer()
                }
                .foregroundStyle(Color(hex: 0xDDE3EC))
            }
        }
    }

    private func load() {
        guard let ep = episodes[safe: current], !ep.url.isEmpty else { return }
        Task {
            var playURL = ep.url
            // 交给解析接口换取可直接播的地址（逐条尝试）
            for parse in state.parses {
                if let resolved = try? await ParseResolver.resolve(parse, playURL: playURL),
                   resolved != playURL { playURL = resolved; break }
            }
            guard let url = URL(string: playURL) else { return }
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            duration = 0; time = 0
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { t in
                time = t.seconds
                if let d = player.currentItem?.duration.seconds, d.isFinite { duration = d }
            }
            player.play(); isPlaying = true
        }
    }

    private func toggle() {
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
    }

    private func seek(_ v: Double) {
        player.seek(to: CMTime(seconds: v, preferredTimescale: 600)); time = v
    }

    private func fmt(_ s: Double) -> String {
        guard s.isFinite, s >= 0 else { return "00:00" }
        return String(format: "%02d:%02d", Int(s) / 60, Int(s) % 60)
    }
}
