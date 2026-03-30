import Foundation

// MARK: - Allowed App (Focus 모드 중에도 사용 가능한 앱)

struct AllowedApp: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var bundleIdentifier: String
    var displayName: String
    var iconSystemName: String
    var isEnabled: Bool

    static let defaults: [AllowedApp] = [
        AllowedApp(id: UUID(), bundleIdentifier: "com.tinyspeck.chatlyio",
                   displayName: "Slack", iconSystemName: "number.square.fill", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.microsoft.teams",
                   displayName: "Microsoft Teams", iconSystemName: "person.3.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.MobileSMS",
                   displayName: "메시지", iconSystemName: "message.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.mobilephone",
                   displayName: "전화", iconSystemName: "phone.fill", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.google.Gmail",
                   displayName: "Gmail", iconSystemName: "envelope.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.apple.iCal",
                   displayName: "캘린더", iconSystemName: "calendar", isEnabled: true),
        AllowedApp(id: UUID(), bundleIdentifier: "com.notion.id",
                   displayName: "Notion", iconSystemName: "doc.text.fill", isEnabled: false),
        AllowedApp(id: UUID(), bundleIdentifier: "com.linear",
                   displayName: "Linear", iconSystemName: "list.bullet.rectangle", isEnabled: false),
    ]
}
