import Foundation
import Combine

// MARK: - Focus View Model
// Central view model that coordinates session tracking, cloud sync, and screen time restrictions

@MainActor
final class FocusViewModel: ObservableObject {
    // MARK: - Published State

    @Published var currentSession: FocusSession?
    @Published var isSessionActive = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var selectedSessionType: SessionType = .study
    @Published var allowedApps: [AllowedApp] = AllowedApp.defaults
    @Published var connectedDevices: [DeviceInfo] = []
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let cloudSync = CloudSyncManager.shared
    private let screenTime = ScreenTimeManager.shared
    private let historyStore = SessionHistoryStore.shared
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    var history: SessionHistoryStore { historyStore }

    // MARK: - Init

    init() {
        loadSavedAllowedApps()
        setupNotificationObservers()
        screenTime.loadSavedSelection()

        // Check for active session on launch (cross-device sync)
        Task { await checkForActiveSession() }
    }

    // MARK: - Session Control

    func startSession() async {
        let session = FocusSession(
            id: UUID(),
            sessionType: selectedSessionType,
            startTime: Date(),
            endTime: nil,
            isActive: true,
            startedFromDeviceID: DeviceInfo.current.id,
            allowedAppIdentifiers: allowedApps.filter(\.isEnabled).map(\.bundleIdentifier)
        )

        currentSession = session
        isSessionActive = true
        startTimer()

        // Activate screen time restrictions on THIS device
        screenTime.activateRestrictions(allowedApps: allowedApps)

        // Sync to cloud → other devices pick it up via push notification
        do {
            try await cloudSync.saveSession(session)
        } catch {
            errorMessage = "동기화 실패: \(error.localizedDescription)"
        }
    }

    func stopSession() async {
        guard var session = currentSession else { return }

        stopTimer()
        session.endTime = Date()
        session.isActive = false
        currentSession = nil
        isSessionActive = false
        elapsedTime = 0

        // Deactivate screen time restrictions
        screenTime.deactivateRestrictions()

        // Sync to cloud
        do {
            try await cloudSync.saveSession(session)
            await historyStore.refreshFromCloud()
        } catch {
            errorMessage = "동기화 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Cross-Device Sync

    /// Called on app launch to check if another device started a session
    func checkForActiveSession() async {
        do {
            if let activeSession = try await cloudSync.fetchActiveSession() {
                currentSession = activeSession
                isSessionActive = true
                startTimer()
                // Activate restrictions on this device too
                screenTime.activateRestrictions(allowedApps: allowedApps)
            }
        } catch {
            print("Failed to check active session: \(error)")
        }
    }

    // MARK: - Allowed Apps Management

    func toggleAllowedApp(_ app: AllowedApp) {
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

    // MARK: - Notification Observers

    private func setupNotificationObservers() {
        // Listen for cross-device session changes (from CloudKit push)
        NotificationCenter.default.publisher(for: .focusSessionChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self else { return }
                if let session = notification.userInfo?["session"] as? FocusSession {
                    if session.isActive {
                        self.currentSession = session
                        self.isSessionActive = true
                        self.startTimer()
                        self.screenTime.activateRestrictions(allowedApps: self.allowedApps)
                    } else {
                        self.currentSession = nil
                        self.isSessionActive = false
                        self.stopTimer()
                        self.elapsedTime = 0
                        self.screenTime.deactivateRestrictions()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Persistence

    private func saveAllowedApps() {
        if let data = try? JSONEncoder().encode(allowedApps) {
            UserDefaults.standard.set(data, forKey: "allowedApps")
        }
    }

    private func loadSavedAllowedApps() {
        guard let data = UserDefaults.standard.data(forKey: "allowedApps"),
              let saved = try? JSONDecoder().decode([AllowedApp].self, from: data)
        else { return }
        allowedApps = saved
    }
}
