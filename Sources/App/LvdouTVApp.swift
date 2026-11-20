import SwiftUI

@main
struct LvdouTVApp: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .preferredColorScheme(.dark)
                .task { await state.load() }
        }
    }
}
