import Foundation

// MARK: - Allowed App (apps that remain usable during focus mode)

struct AllowedApp: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var bundleIdentifier: String
    var displayName: String
    var iconSystemName: String
    var isEnabled: Bool  // Whether this app is currently allowed during focus

    static let defaults: [AllowedApp] = [
        AllowedApp(id: UUID(), bundleIdentifier: "com.tinyspeck.chatlyio",
                   displayName: "Slack", iconSystemName: "bubble.left.fill", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.microsoft.teams",
                   displayName: "Microsoft Teams", iconSystemName: "person.3.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.MobileSMS",
                   displayName: "메시지", iconSystemName: "message.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.mobilephone",
                   displayName: "전화", iconSystemName: "phone.fill", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.google.Gmail",
                   displayName: "Gmail", iconSystemName: "envelope.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.reminders",
                   displayName: "미리알림", iconSystemName: "checklist", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.iCal",
                   displayName: "캘린더", iconSystemName: "calendar", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.readdle.smartemail",
                   displayName: "Spark Mail", iconSystemName: "envelope.open.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.notion.id",
                   displayName: "Notion", iconSystemName: "doc.text.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.linear",
                   displayName: "Linear", iconSystemName: "list.bullet.rectangle", isEnabled: false),
    ]
}

// MARK: - App Category Presets

enum AppPresetCategory: String, CaseIterable, Identifiable {
    case communication = "커뮤니케이션"
    case productivity = "생산성"
    case custom = "사용자 지정"

    var id: String { rawValue }

    var defaultBundleIDs: [String] {
        switch self {
        case .communication:
            return [
                "com.tinyspeck.chatlyio",  // Slack
                "com.microsoft.teams",
                "com.apple.MobileSMS",
                "com.apple.mobilephone"
            ]
        case .productivity:
            return [
                "com.notion.id",
                "com.linear",
                "com.apple.iCal",
                "com.apple.reminders"
            ]
        case .custom:
            return []
        }
    }
}
