import SwiftUI

@main
struct FocusSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - App Delegate (handles CloudKit push notifications)

#if os(iOS)
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register for remote notifications (CloudKit push)
        application.registerForRemoteNotifications()

        // Setup CloudKit subscription
        CloudSyncManager.shared.setupSubscription()

        // Request Screen Time authorization
        Task {
            try? await ScreenTimeManager.shared.requestAuthorization()
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [String: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Task {
            await CloudSyncManager.shared.handleRemoteNotification(userInfo: userInfo)
            completionHandler(.newData)
        }
    }
}

#elseif os(macOS)
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.registerForRemoteNotifications()
        CloudSyncManager.shared.setupSubscription()

        Task {
            try? await ScreenTimeManager.shared.requestAuthorization()
        }
    }

    func application(
        _ application: NSApplication,
        didReceiveRemoteNotification userInfo: [String: Any]
    ) {
        Task {
            await CloudSyncManager.shared.handleRemoteNotification(userInfo: userInfo)
        }
    }
}
#endif
