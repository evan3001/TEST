import Foundation
import CloudKit
import Combine

// MARK: - Cloud Sync Manager
// Uses iCloud Private Database + CKSubscription for real-time cross-device sync

final class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()

    private let container = CKContainer(identifier: "iCloud.com.focussync.app")
    private var database: CKDatabase { container.privateCloudDatabase }
    private var subscriptionID = "active-session-changes"
    private var cancellables = Set<AnyCancellable>()

    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncError: String?

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case synced
        case error
    }

    private init() {}

    // MARK: - Setup Subscription (real-time push notifications on data change)

    func setupSubscription() {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        let subscription = CKQuerySubscription(
            recordType: FocusSession.recordType,
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )

        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true  // Silent push
        notificationInfo.desiredKeys = ["isActive", "sessionType", "startTime"]
        subscription.notificationInfo = notificationInfo

        database.save(subscription) { _, error in
            if let error = error as? CKError, error.code != .serverRejectedRequest {
                print("Subscription setup error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Save Session

    func saveSession(_ session: FocusSession) async throws {
        syncStatus = .syncing
        let record = session.toRecord()

        do {
            let _ = try await database.save(record)
            await MainActor.run { self.syncStatus = .synced }
        } catch {
            await MainActor.run {
                self.syncStatus = .error
                self.lastSyncError = error.localizedDescription
            }
            throw error
        }
    }

    // MARK: - Fetch Active Session

    func fetchActiveSession() async throws -> FocusSession? {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        let query = CKQuery(recordType: FocusSession.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        let (results, _) = try await database.records(matching: query, resultsLimit: 1)
        for (_, result) in results {
            if let record = try? result.get() {
                return FocusSession.fromRecord(record)
            }
        }
        return nil
    }

    // MARK: - Fetch Session History

    func fetchSessionHistory(limit: Int = 50) async throws -> [FocusSession] {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: false))
        let query = CKQuery(recordType: FocusSession.recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        let (results, _) = try await database.records(matching: query, resultsLimit: limit)
        return results.compactMap { _, result in
            guard let record = try? result.get() else { return nil }
            return FocusSession.fromRecord(record)
        }
    }

    // MARK: - End Session

    func endSession(_ session: FocusSession) async throws {
        var updated = session
        updated.endTime = Date()
        updated.isActive = false
        try await saveSession(updated)
    }

    // MARK: - Handle Remote Notification (called from AppDelegate)

    func handleRemoteNotification(userInfo: [String: Any]) async {
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String: NSObject])
        guard notification?.subscriptionID == subscriptionID else { return }

        // Fetch the latest active session and notify observers
        do {
            let session = try await fetchActiveSession()
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .focusSessionChanged,
                    object: nil,
                    userInfo: ["session": session as Any]
                )
            }
        } catch {
            print("Failed to fetch session on notification: \(error)")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let focusSessionChanged = Notification.Name("focusSessionChanged")
    static let focusShouldActivate = Notification.Name("focusShouldActivate")
    static let focusShouldDeactivate = Notification.Name("focusShouldDeactivate")
}
