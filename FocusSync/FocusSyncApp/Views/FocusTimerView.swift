import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var vm: FocusViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // 세션 타입 선택
                if !vm.isSessionActive {
                    sessionTypePicker
                }

                // 타이머
                timerDisplay

                // 시작/종료 버튼
                actionButton

                // 오늘 요약
                todaySummary

                Spacer()

                // 동기화 상태 (데모)
                HStack(spacing: 6) {
                    Circle().fill(.green).frame(width: 6, height: 6)
                    Text("3개 기기 연결됨")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .navigationTitle("FocusSync")
        }
    }

    // MARK: - Session Type Picker

    private var sessionTypePicker: some View {
        HStack(spacing: 16) {
            ForEach(SessionType.allCases) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.selectedSessionType = type
                    }
                } label: {
                    let isSelected = vm.selectedSessionType == type
                    let color: Color = type == .study ? .blue : .orange

                    VStack(spacing: 8) {
                        Image(systemName: type.iconName)
                            .font(.title2)
                        Text(type.displayName)
                            .font(.subheadline.weight(.medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? color.opacity(0.12) : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color : .clear, lineWidth: 2)
                    )
                    .foregroundStyle(isSelected ? color : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            if vm.isSessionActive {
                HStack(spacing: 4) {
                    Circle().fill(.red).frame(width: 8, height: 8)
                    Text("\(vm.currentSession?.sessionType.displayName ?? "") 진행 중")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(formattedTime)
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: vm.elapsedTime)
        }
    }

    private var formattedTime: String {
        let total = Int(vm.elapsedTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            if vm.isSessionActive {
                vm.stopSession()
            } else {
                vm.startSession()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: vm.isSessionActive ? "stop.fill" : "play.fill")
                Text(vm.isSessionActive ? "종료" : "시작")
                    .font(.title3.weight(.semibold))
            }
            .frame(width: 200, height: 56)
            .background(Capsule().fill(vm.isSessionActive ? .red : .blue))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today Summary

    private var todaySummary: some View {
        HStack(spacing: 24) {
            statItem(title: "오늘 공부", seconds: vm.store.todayStudyTime, color: .blue)
            Divider().frame(height: 40)
            statItem(title: "오늘 업무", seconds: vm.store.todayWorkTime, color: .orange)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
    }

    private func statItem(title: String, seconds: TimeInterval, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(formatDuration(seconds))
                .font(.headline)
                .foregroundStyle(color)
        }
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}
