import Foundation

// MARK: - Session Store
// 데모 버전: UserDefaults 기반 로컬 저장 (프로덕션에서는 CloudKit으로 교체)

final class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var sessions: [FocusSession] = []

    private let storageKey = "focusSessions"

    private init() {
        loadSessions()
    }

    // MARK: - Save

    func addSession(_ session: FocusSession) {
        sessions.insert(session, at: 0)
        persist()
    }

    func updateSession(_ session: FocusSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            persist()
        }
    }

    // MARK: - Query

    var todaySessions: [FocusSession] {
        sessions.filter { Calendar.current.isDateInToday($0.startTime) }
    }

    var todayStudyTime: TimeInterval {
        todaySessions.filter { $0.sessionType == .study }.reduce(0) { $0 + $1.duration }
    }

    var todayWorkTime: TimeInterval {
        todaySessions.filter { $0.sessionType == .work }.reduce(0) { $0 + $1.duration }
    }

    var weeklyStudyTime: TimeInterval {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return sessions
            .filter { $0.sessionType == .study && $0.startTime >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }

    var weeklyWorkTime: TimeInterval {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return sessions
            .filter { $0.sessionType == .work && $0.startTime >= weekAgo }
            .reduce(0) { $0 + $1.duration }
    }

    func sessionsGroupedByDate() -> [(date: Date, sessions: [FocusSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions.filter { !$0.isActive }) {
            calendar.startOfDay(for: $0.startTime)
        }
        return grouped
            .map { (date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Persistence (UserDefaults)

    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([FocusSession].self, from: data)
        else {
            // 데모용 샘플 데이터
            sessions = Self.generateSampleData()
            return
        }
        sessions = saved
    }

    // MARK: - Sample Data (데모)

    static func generateSampleData() -> [FocusSession] {
        let calendar = Calendar.current
        let now = Date()
        var samples: [FocusSession] = []

        // 지난 7일간의 데모 데이터
        for daysAgo in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -daysAgo, to: now) else { continue }

            // 오전 공부 세션
            if let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: day),
               let end = calendar.date(byAdding: .minute, value: Int.random(in: 45...120), to: start) {
                samples.append(FocusSession(
                    id: UUID(), sessionType: .study, startTime: start, endTime: end,
                    isActive: false, deviceName: "iPhone 15 Pro", allowedAppIDs: []
                ))
            }

            // 오후 업무 세션
            if let start = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: day),
               let end = calendar.date(byAdding: .minute, value: Int.random(in: 60...180), to: start) {
                samples.append(FocusSession(
                    id: UUID(), sessionType: .work, startTime: start, endTime: end,
                    isActive: false, deviceName: "MacBook Pro", allowedAppIDs: []
                ))
            }

            // 저녁 공부 세션 (가끔)
            if daysAgo % 2 == 0,
               let start = calendar.date(bySettingHour: 20, minute: 30, second: 0, of: day),
               let end = calendar.date(byAdding: .minute, value: Int.random(in: 30...90), to: start) {
                samples.append(FocusSession(
                    id: UUID(), sessionType: .study, startTime: start, endTime: end,
                    isActive: false, deviceName: "iPad Air", allowedAppIDs: []
                ))
            }
        }

        return samples.sorted { $0.startTime > $1.startTime }
    }
}
