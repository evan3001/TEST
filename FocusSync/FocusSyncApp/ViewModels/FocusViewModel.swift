import Foundation
import SwiftUI

// MARK: - Focus View Model

@MainActor
final class FocusViewModel: ObservableObject {
    // MARK: - State

    @Published var currentSession: FocusSession?
    @Published var isSessionActive = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var selectedSessionType: SessionType = .study
    @Published var allowedApps: [AllowedApp] = AllowedApp.defaults
    @Published var devices: [DeviceInfo] = DeviceInfo.demoDevices
    @Published var isFocusShieldShowing = false

    let store = SessionStore.shared
    private var timer: Timer?

    // MARK: - Init

    init() {
        loadAllowedApps()
    }

    // MARK: - Session Control

    func startSession() {
        let session = FocusSession(
            id: UUID(),
            sessionType: selectedSessionType,
            startTime: Date(),
            endTime: nil,
            isActive: true,
            deviceName: currentDeviceName(),
            allowedAppIDs: allowedApps.filter(\.isEnabled).map(\.bundleIdentifier)
        )

        currentSession = session
        isSessionActive = true
        isFocusShieldShowing = true
        store.addSession(session)
        startTimer()

        // 데모: 모든 기기 focus 활성화 표시
        for i in devices.indices {
            devices[i].isFocusActive = true
        }
    }

    func stopSession() {
        guard var session = currentSession else { return }

        stopTimer()
        session.endTime = Date()
        session.isActive = false
        store.updateSession(session)

        currentSession = nil
        isSessionActive = false
        isFocusShieldShowing = false
        elapsedTime = 0

        // 데모: 모든 기기 focus 비활성화
        for i in devices.indices {
            devices[i].isFocusActive = false
        }
    }

    // MARK: - Allowed Apps

    func toggleApp(_ app: AllowedApp) {
        if let index = allowedApps.firstIndex(where: { $0.id == app.id }) {
            allowedApps[index].isEnabled.toggle()
            saveAllowedApps()
        }
    }

    func addCustomApp(bundleID: String, name: String) {
        let app = AllowedApp(
            id: UUID(),
            bundleIdentifier: bundleID,
            displayName: name,
            iconSystemName: "app.fill",
            isEnabled: true
        )
        allowedApps.append(app)
        saveAllowedApps()
    }

    func removeApp(at offsets: IndexSet) {
        allowedApps.remove(atOffsets: offsets)
        saveAllowedApps()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let session = self.currentSession else { return }
                self.elapsedTime = Date().timeIntervalSince(session.startTime)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Helpers

    private func currentDeviceName() -> String {
        #if os(iOS)
        return UIDevice.current.name
        #else
        return Host.current().localizedName ?? "Mac"
        #endif
    }

    private func saveAllowedApps() {
        if let data = try? JSONEncoder().encode(allowedApps) {
            UserDefaults.standard.set(data, forKey: "allowedApps")
        }
    }

    private func loadAllowedApps() {
        guard let data = UserDefaults.standard.data(forKey: "allowedApps"),
              let saved = try? JSONDecoder().decode([AllowedApp].self, from: data)
        else { return }
        allowedApps = saved
    }
}
