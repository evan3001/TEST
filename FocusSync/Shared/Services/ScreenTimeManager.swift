import Foundation
import Combine

// MARK: - Screen Time Manager
// Manages app restrictions using Apple's Screen Time API (FamilyControls + ManagedSettings)
//
// NOTE: On iOS/iPadOS, this uses the ManagedSettings framework to shield (block) apps.
// On macOS, Screen Time API is limited — we use a combination of NSWorkspace monitoring
// and user-level restrictions as a best-effort approach.

#if canImport(FamilyControls) && canImport(ManagedSettings) && canImport(DeviceActivity)
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - iOS/iPadOS Implementation (Full Screen Time API)

final class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared

    @Published var isAuthorized = false
    @Published var isRestrictionActive = false
    @Published var selectedAppsToBlock = FamilyActivitySelection()
    @Published var allowedBundleIDs: Set<String> = []

    private init() {}

    // MARK: - Request Authorization

    func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
        await MainActor.run { self.isAuthorized = true }
    }

    // MARK: - Activate Focus Restrictions

    func activateRestrictions(allowedApps: [AllowedApp]) {
        let enabledAllowedBundleIDs = Set(
            allowedApps.filter(\.isEnabled).map(\.bundleIdentifier)
        )
        self.allowedBundleIDs = enabledAllowedBundleIDs

        // Shield all apps except the allowed ones
        // FamilyActivitySelection contains the apps/categories user picked to block
        store.shield.applications = selectedAppsToBlock.applicationTokens
        store.shield.applicationCategories = .specific(selectedAppsToBlock.categoryTokens)
        store.shield.webDomainCategories = .specific(selectedAppsToBlock.categoryTokens)

        isRestrictionActive = true
    }

    // MARK: - Deactivate Focus Restrictions

    func deactivateRestrictions() {
        store.clearAllSettings()
        isRestrictionActive = false
    }

    // MARK: - Update Blocked App Selection

    func updateBlockedApps(_ selection: FamilyActivitySelection) {
        selectedAppsToBlock = selection
        // Persist selection
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(selection) {
            UserDefaults.standard.set(data, forKey: "blockedAppsSelection")
        }
    }

    // MARK: - Load Saved Selection

    func loadSavedSelection() {
        guard let data = UserDefaults.standard.data(forKey: "blockedAppsSelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }
        selectedAppsToBlock = selection
    }
}

#else

// MARK: - macOS Fallback Implementation

final class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    @Published var isAuthorized = false
    @Published var isRestrictionActive = false
    @Published var allowedBundleIDs: Set<String> = []
    @Published var blockedBundleIDs: Set<String> = []

    private var monitorTimer: Timer?

    private init() {}

    func requestAuthorization() async throws {
        // On macOS, Screen Time API (ManagedSettings) is not available for third-party apps.
        // We use a notification-based approach instead.
        await MainActor.run { self.isAuthorized = true }
    }

    /// On macOS, we monitor running apps and show overlay/notification when blocked app is opened
    func activateRestrictions(allowedApps: [AllowedApp]) {
        let enabledAllowedBundleIDs = Set(
            allowedApps.filter(\.isEnabled).map(\.bundleIdentifier)
        )
        self.allowedBundleIDs = enabledAllowedBundleIDs
        isRestrictionActive = true

        #if os(macOS)
        startMonitoringApps()
        #endif
    }

    func deactivateRestrictions() {
        isRestrictionActive = false
        #if os(macOS)
        stopMonitoringApps()
        #endif
    }

    #if os(macOS)
    import AppKit

    private func startMonitoringApps() {
        // Monitor frontmost app changes
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
    }

    private func stopMonitoringApps() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc private func appDidActivate(_ notification: Notification) {
        guard isRestrictionActive,
              let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = app.bundleIdentifier
        else { return }

        // If the app is in blocked list and NOT in allowed list, show warning
        if blockedBundleIDs.contains(bundleID) && !allowedBundleIDs.contains(bundleID) {
            showBlockedAppNotification(appName: app.localizedName ?? bundleID)
        }
    }

    private func showBlockedAppNotification(appName: String) {
        let notification = NSUserNotification()
        notification.title = "FocusSync"
        notification.informativeText = "'\(appName)'은(는) 집중 모드 중 사용이 제한됩니다."
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    #endif

    func updateBlockedApps(_ bundleIDs: Set<String>) {
        blockedBundleIDs = bundleIDs
        UserDefaults.standard.set(Array(bundleIDs), forKey: "blockedBundleIDs")
    }

    func loadSavedSelection() {
        if let saved = UserDefaults.standard.array(forKey: "blockedBundleIDs") as? [String] {
            blockedBundleIDs = Set(saved)
        }
    }
}

#endif
