import SwiftUI

struct LiveView: View {
    private let channels = ["CCTV-1", "CCTV-5", "CCTV-6", "湖南卫视", "浙江卫视", "东方卫视", "江苏卫视", "北京卫视"]
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                Text("直播").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                    ForEach(channels, id: \.self) { c in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(LinearGradient(colors: [Color(hex: 0x1F5E56), Color(hex: 0x2B4C86)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(height: 64)
                                .overlay(
                                    HStack(spacing: 4) {
                                        Circle().fill(Color(hex: 0xFF5A5A)).frame(width: 5, height: 5)
                                        Text("LIVE").font(.system(size: 8, weight: .bold)).foregroundStyle(.white)
                                    }.padding(6), alignment: .topLeading)
                            Text(c).font(.system(size: 11.5)).foregroundStyle(Color(hex: 0xDDE3EC))
                        }
                    }
                }
                Color.clear.frame(height: 96)
            }
            .padding(16)
        }
    }
}
