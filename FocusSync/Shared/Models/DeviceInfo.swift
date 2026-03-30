import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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

    var displayName: String {
        switch self {
        case .iPhone: return "iPhone"
        case .iPad: return "iPad"
        case .mac: return "MacBook"
        }
    }
}

// MARK: - Device Info

struct DeviceInfo: Identifiable, Codable, Equatable {
    let id: String  // Unique device identifier
    var name: String
    var deviceType: DeviceType
    var lastSeen: Date
    var isFocusActive: Bool

    static var current: DeviceInfo {
        let deviceID = currentDeviceID()
        let name: String
        let type: DeviceType

        #if os(iOS)
        let device = UIDevice.current
        name = device.name
        type = device.userInterfaceIdiom == .pad ? .iPad : .iPhone
        #elseif os(macOS)
        name = Host.current().localizedName ?? "Mac"
        type = .mac
        #else
        name = "Unknown"
        type = .iPhone
        #endif

        return DeviceInfo(
            id: deviceID,
            name: name,
            deviceType: type,
            lastSeen: Date(),
            isFocusActive: false
        )
    }

    private static func currentDeviceID() -> String {
        let key = "com.focussync.deviceID"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
