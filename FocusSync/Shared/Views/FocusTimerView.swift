import SwiftUI

// MARK: - Focus Timer View (Main Screen)

struct FocusTimerView: View {
    @EnvironmentObject var viewModel: FocusViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Session Type Selector
                if !viewModel.isSessionActive {
                    sessionTypePicker
                }

                // Timer Display
                timerDisplay

                // Start/Stop Button
                actionButton

                // Today's Summary
                todaySummary

                Spacer()

                // Sync Status
                syncStatusBar
            }
            .padding()
            .navigationTitle("FocusSync")
            .background(
                viewModel.isSessionActive
                    ? (viewModel.selectedSessionType == .study
                        ? Color.blue.opacity(0.05)
                        : Color.orange.opacity(0.05))
                    : Color.clear
            )
        }
    }

    // MARK: - Session Type Picker

    private var sessionTypePicker: some View {
        HStack(spacing: 16) {
            ForEach(SessionType.allCases) { type in
                Button {
                    viewModel.selectedSessionType = type
                } label: {
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
                            .fill(viewModel.selectedSessionType == type
                                  ? (type == .study ? Color.blue : Color.orange).opacity(0.15)
                                  : Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(viewModel.selectedSessionType == type
                                    ? (type == .study ? Color.blue : Color.orange)
                                    : Color.clear,
                                    lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            if viewModel.isSessionActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text(viewModel.currentSession?.sessionType.displayName ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("진행 중")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text(formattedTime)
                .font(.system(size: 64, weight: .thin, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.linear(duration: 0.1), value: viewModel.elapsedTime)
        }
    }

    private var formattedTime: String {
        let total = Int(viewModel.elapsedTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button {
            Task {
                if viewModel.isSessionActive {
                    await viewModel.stopSession()
                } else {
                    await viewModel.startSession()
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isSessionActive ? "stop.fill" : "play.fill")
                Text(viewModel.isSessionActive ? "종료" : "시작")
                    .font(.title3.weight(.semibold))
            }
            .frame(width: 200, height: 56)
            .background(
                Capsule()
                    .fill(viewModel.isSessionActive ? Color.red : Color.blue)
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Summary

    private var todaySummary: some View {
        HStack(spacing: 24) {
            summaryItem(
                title: "오늘 공부",
                duration: viewModel.history.todayStudyTime,
                color: .blue
            )
            Divider().frame(height: 40)
            summaryItem(
                title: "오늘 업무",
                duration: viewModel.history.todayWorkTime,
                color: .orange
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    private func summaryItem(title: String, duration: TimeInterval, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(formatDuration(duration))
                .font(.headline)
                .foregroundStyle(color)
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        }
        return "\(minutes)분"
    }

    // MARK: - Sync Status

    private var syncStatusBar: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(CloudSyncManager.shared.syncStatus == .synced ? Color.green : Color.gray)
                .frame(width: 6, height: 6)
            Text(syncStatusText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var syncStatusText: String {
        switch CloudSyncManager.shared.syncStatus {
        case .idle: return "대기 중"
        case .syncing: return "동기화 중..."
        case .synced: return "모든 기기와 동기화됨"
        case .error: return "동기화 오류"
        }
    }
}
