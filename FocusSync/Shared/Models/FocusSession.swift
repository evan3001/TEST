import Foundation
import CloudKit

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
    var startedFromDeviceID: String
    var allowedAppIdentifiers: [String]  // Bundle IDs of apps allowed during focus

    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d시간 %02d분 %02d초", hours, minutes, seconds)
        } else {
            return String(format: "%02d분 %02d초", minutes, seconds)
        }
    }

    // MARK: - CloudKit Record Conversion

    static let recordType = "FocusSession"

    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: Self.recordType,
                              recordID: CKRecord.ID(recordName: id.uuidString))
        record["sessionType"] = sessionType.rawValue
        record["startTime"] = startTime
        record["endTime"] = endTime
        record["isActive"] = isActive
        record["startedFromDeviceID"] = startedFromDeviceID
        record["allowedAppIdentifiers"] = allowedAppIdentifiers as [String]
        return record
    }

    static func fromRecord(_ record: CKRecord) -> FocusSession? {
        guard
            let id = UUID(uuidString: record.recordID.recordName),
            let typeRaw = record["sessionType"] as? String,
            let sessionType = SessionType(rawValue: typeRaw),
            let startTime = record["startTime"] as? Date,
            let isActive = record["isActive"] as? Bool,
            let deviceID = record["startedFromDeviceID"] as? String
        else { return nil }

        return FocusSession(
            id: id,
            sessionType: sessionType,
            startTime: startTime,
            endTime: record["endTime"] as? Date,
            isActive: isActive,
            startedFromDeviceID: deviceID,
            allowedAppIdentifiers: (record["allowedAppIdentifiers"] as? [String]) ?? []
        )
    }
}
