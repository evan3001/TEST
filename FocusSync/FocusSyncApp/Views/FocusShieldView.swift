import SwiftUI

// 집중 모드 활성화 시 전체화면 오버레이

struct FocusShieldView: View {
    @EnvironmentObject var vm: FocusViewModel
    @State private var showStopConfirm = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.8))

                Text("집중 모드")
                    .font(.title.weight(.semibold))
                    .foregroundStyle(.white)

                Text(vm.currentSession?.sessionType.displayName ?? "")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.6))

                // 타이머
                Text(formattedTime)
                    .font(.system(size: 56, weight: .thin, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                // 허용된 앱 목록
                VStack(spacing: 8) {
                    Text("사용 가능한 앱")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))

                    HStack(spacing: 16) {
                        ForEach(vm.allowedApps.filter(\.isEnabled).prefix(5)) { app in
                            VStack(spacing: 4) {
                                Image(systemName: app.iconSystemName)
                                    .font(.title3)
                                Text(app.displayName)
                                    .font(.caption2)
                            }
                            .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.top, 16)

                Spacer()

                // 기기 상태
                HStack(spacing: 20) {
                    ForEach(vm.devices) { device in
                        VStack(spacing: 4) {
                            Image(systemName: device.deviceType.iconName)
                                .font(.title3)
                            Circle()
                                .fill(device.isFocusActive ? .green : .gray)
                                .frame(width: 6, height: 6)
                        }
                        .foregroundStyle(.white.opacity(0.6))
                    }
                }

                // 해제 버튼
                Button("집중 모드 해제") {
                    showStopConfirm = true
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .alert("집중 모드를 종료하시겠습니까?", isPresented: $showStopConfirm) {
            Button("취소", role: .cancel) {}
            Button("종료", role: .destructive) {
                vm.stopSession()
            }
        } message: {
            Text("모든 기기의 집중 모드가 해제됩니다.")
        }
    }

    private var formattedTime: String {
        let total = Int(vm.elapsedTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
