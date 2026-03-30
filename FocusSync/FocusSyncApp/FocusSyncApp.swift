import SwiftUI

@main
struct FocusSyncApp: App {
    @StateObject private var viewModel = FocusViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
        }
    }
}
