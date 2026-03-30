import SwiftUI

// MARK: - Devices View
// Shows connected devices and their focus status

struct DevicesView: View {
    @EnvironmentObject var viewModel: FocusViewModel
    @State private var currentDevice = DeviceInfo.current

    var body: some View {
        NavigationStack {
            List {
                // Current Device
                Section("이 기기") {
                    deviceRow(
                        device: currentDevice,
                        isCurrent: true,
                        isFocusActive: viewModel.isSessionActive
                    )
                }

                // Other Devices
                Section("연결된 기기") {
                    if viewModel.connectedDevices.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "icloud")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("같은 iCloud 계정으로 로그인된 기기가\n자동으로 여기에 표시됩니다.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(viewModel.connectedDevices) { device in
                            deviceRow(
                                device: device,
                                isCurrent: false,
                                isFocusActive: device.isFocusActive
                            )
                        }
                    }
                }

                // How it works
                Section("동작 방식") {
                    InfoRow(
                        icon: "icloud.fill",
                        title: "iCloud 동기화",
                        description: "모든 세션 데이터가 iCloud를 통해 실시간 동기화됩니다."
                    )
                    InfoRow(
                        icon: "bell.badge.fill",
                        title: "푸시 알림",
                        description: "한 기기에서 집중 모드를 시작하면 다른 기기에 즉시 알림이 갑니다."
                    )
                    InfoRow(
                        icon: "lock.shield.fill",
                        title: "Screen Time API",
                        description: "iOS/iPadOS에서는 Screen Time API로 앱을 차단합니다."
                    )
                }
            }
            .navigationTitle("기기")
        }
    }

    // MARK: - Device Row

    private func deviceRow(device: DeviceInfo, isCurrent: Bool, isFocusActive: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: device.deviceType.iconName)
                .font(.title2)
                .foregroundStyle(isFocusActive ? .blue : .secondary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(device.name)
                        .font(.body.weight(.medium))
                    if isCurrent {
                        Text("현재")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.blue.opacity(0.15)))
                            .foregroundStyle(.blue)
                    }
                }

                Text(device.deviceType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isFocusActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                    Text("집중 중")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else {
                Text("대기")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
