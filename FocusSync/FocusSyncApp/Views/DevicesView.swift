import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var vm: FocusViewModel

    var body: some View {
        NavigationStack {
            List {
                // 기기 목록
                Section("연결된 기기") {
                    ForEach(vm.devices) { device in
                        HStack(spacing: 14) {
                            Image(systemName: device.deviceType.iconName)
                                .font(.title2)
                                .foregroundStyle(device.isFocusActive ? .blue : .secondary)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(device.name)
                                    .font(.body.weight(.medium))
                                Text(device.deviceType.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if device.isFocusActive {
                                HStack(spacing: 4) {
                                    Circle().fill(.red).frame(width: 6, height: 6)
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
                        .padding(.vertical, 6)
                    }
                }

                // 설명
                Section("동작 방식") {
                    infoRow(icon: "icloud.fill",
                            title: "iCloud 동기화",
                            desc: "같은 Apple ID로 로그인된 기기가 자동 연결됩니다.")
                    infoRow(icon: "bell.badge.fill",
                            title: "동시 알림",
                            desc: "한 기기에서 시작하면 모든 기기에서 동시에 집중 모드가 켜집니다.")
                    infoRow(icon: "lock.shield.fill",
                            title: "앱 차단",
                            desc: "설정한 앱 외에는 모든 기기에서 사용이 제한됩니다.")
                }

                // 데모 배지
                Section {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.purple)
                        Text("데모 모드 — 실제 크로스 디바이스 동기화는 iCloud 연동 후 활성화됩니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("기기")
        }
    }

    private func infoRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.medium))
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
