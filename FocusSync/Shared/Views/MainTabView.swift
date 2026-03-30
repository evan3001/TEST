import SwiftUI

// MARK: - Main Tab View (Entry Point)

struct MainTabView: View {
    @StateObject private var viewModel = FocusViewModel()

    var body: some View {
        TabView {
            FocusTimerView()
                .tabItem {
                    Label("타이머", systemImage: "timer")
                }

            HistoryView()
                .tabItem {
                    Label("기록", systemImage: "clock.arrow.circlepath")
                }

            AllowedAppsView()
                .tabItem {
                    Label("앱 설정", systemImage: "app.badge.checkmark")
                }

            DevicesView()
                .tabItem {
                    Label("기기", systemImage: "desktopcomputer")
                }
        }
        .environmentObject(viewModel)
        .tint(.blue)
    }
}
