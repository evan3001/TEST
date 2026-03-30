import SwiftUI

// MARK: - Focus Shield View
// Full-screen overlay shown on devices when focus mode is active
// Acts as a visual deterrent on macOS where Screen Time API is unavailable

struct FocusShieldView: View {
    @EnvironmentObject var viewModel: FocusViewModel
    @State private var showUnlockConfirm = false

    var body: some View {
        if viewModel.isSessionActive {
            ZStack {
                // Blurred background
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("집중 모드 진행 중")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(viewModel.currentSession?.sessionType.displayName ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(formattedElapsed)
                        .font(.system(size: 40, weight: .thin, design: .monospaced))
                        .foregroundStyle(.white)

                    Button("집중 모드 해제") {
                        showUnlockConfirm = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 32)
                }
            }
            .alert("집중 모드를 종료하시겠습니까?", isPresented: $showUnlockConfirm) {
                Button("취소", role: .cancel) {}
                Button("종료", role: .destructive) {
                    Task { await viewModel.stopSession() }
                }
            } message: {
                Text("모든 기기의 집중 모드가 해제됩니다.")
            }
        }
    }

    private var formattedElapsed: String {
        let total = Int(viewModel.elapsedTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
