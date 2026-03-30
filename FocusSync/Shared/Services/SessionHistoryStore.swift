import Foundation
import Combine

// MARK: - Session History Store
// Local cache + CloudKit sync for session history

final class SessionHistoryStore: ObservableObject {
    static let shared = SessionHistoryStore()

    @Published var sessions: [FocusSession] = []
    @Published var isLoading = false

    private let cloudSync = CloudSyncManager.shared
    private let localCacheKey = "cachedSessions"

    private init() {
        loadLocalCache()
    }

    // MARK: - Fetch from Cloud

    func refreshFromCloud() async {
        await MainActor.run { isLoading = true }

        do {
            let cloudSessions = try await cloudSync.fetchSessionHistory(limit: 100)
            await MainActor.run {
                self.sessions = cloudSessions
                self.isLoading = false
                self.saveLocalCache()
            }
        } catch {
            await MainActor.run { self.isLoading = false }
            print("Failed to fetch history: \(error)")
        }
    }

    // MARK: - Statistics

    var todaySessions: [FocusSession] {
        let calendar = Calendar.current
        return sessions.filter { calendar.isDateInToday($0.startTime) }
    }

    var todayStudyTime: TimeInterval {
        todaySessions
            .filter { $0.sessionType == .study }
            .reduce(0) { $0 + $1.duration }
    }

    var todayWorkTime: TimeInterval {
        todaySessions
            .filter { $0.sessionType == .work }
            .reduce(0) { $0 + $1.duration }
    }

    var weeklyStudyTime: TimeInterval {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return sessions
            .filter { $0.sessionType == .study && $0.startTime >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }

    var weeklyWorkTime: TimeInterval {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return sessions
            .filter { $0.sessionType == .work && $0.startTime >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }

    func sessionsGroupedByDate() -> [(date: Date, sessions: [FocusSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        return grouped
            .map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Local Cache

    private func saveLocalCache() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: localCacheKey)
        }
    }

    private func loadLocalCache() {
        guard let data = UserDefaults.standard.data(forKey: localCacheKey),
              let cached = try? JSONDecoder().decode([FocusSession].self, from: data)
        else { return }
        sessions = cached
    }
}
