import Foundation

// MARK: - Device Type

enum DeviceType: String, Codable, CaseIterable {
    case iPhone
    case iPad
    case mac

    var iconName: String {
        switch self {
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .mac: return "laptopcomputer"
        }
    }

    var displayName: String { rawValue }
}

// MARK: - Device Info

struct DeviceInfo: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var deviceType: DeviceType
    var isFocusActive: Bool

    // 데모용 기기 목록
    static let demoDevices: [DeviceInfo] = [
        DeviceInfo(id: "iphone-1", name: "나의 iPhone 15 Pro", deviceType: .iPhone, isFocusActive: false),
        DeviceInfo(id: "ipad-1", name: "나의 iPad Air", deviceType: .iPad, isFocusActive: false),
        DeviceInfo(id: "mac-1", name: "나의 MacBook Pro", deviceType: .mac, isFocusActive: false),
    ]
}
