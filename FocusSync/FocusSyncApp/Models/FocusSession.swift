import Foundation

// MARK: - Session Type

enum SessionType: String, Codable, CaseIterable, Identifiable {
    case study = "study"
    case work = "work"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .study: return "공부"
        case .work: return "업무"
        }
    }

    var iconName: String {
        switch self {
        case .study: return "book.fill"
        case .work: return "briefcase.fill"
        }
    }
}

// MARK: - Focus Session

struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    var sessionType: SessionType
    var startTime: Date
    var endTime: Date?
    var isActive: Bool
    var deviceName: String
    var allowedAppIDs: [String]

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d시간 %02d분 %02d초", h, m, s)
        }
        return String(format: "%02d분 %02d초", m, s)
    }
}
