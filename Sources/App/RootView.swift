import SwiftUI

struct RootView: View {
    @State private var tab: DockTab = .home
    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()
            Group {
                switch tab {
                case .home: HomeView()
                case .live: LiveView()
                case .mine: MineView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            DockBar(selection: $tab)
        }
        .ignoresSafeArea(.keyboard)
    }
}
