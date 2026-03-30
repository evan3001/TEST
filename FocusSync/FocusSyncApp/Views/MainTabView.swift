import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var vm: FocusViewModel

    var body: some View {
        ZStack {
            TabView {
                FocusTimerView()
                    .tabItem { Label("타이머", systemImage: "timer") }

                HistoryView()
                    .tabItem { Label("기록", systemImage: "clock.arrow.circlepath") }

                AllowedAppsView()
                    .tabItem { Label("앱 설정", systemImage: "app.badge.checkmark") }

                DevicesView()
                    .tabItem { Label("기기", systemImage: "desktopcomputer") }
            }
            .tint(.blue)

            // Focus Shield overlay
            if vm.isFocusShieldShowing {
                FocusShieldView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.isFocusShieldShowing)
    }
}
