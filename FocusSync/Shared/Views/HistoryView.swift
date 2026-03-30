import SwiftUI

// MARK: - History View
// Shows past focus sessions grouped by date, synced across all devices

struct HistoryView: View {
    @EnvironmentObject var viewModel: FocusViewModel

    var body: some View {
        NavigationStack {
            List {
                // Weekly Summary
                Section("이번 주 요약") {
                    weeklySummaryCard
                }

                // Session History by Date
                let grouped = viewModel.history.sessionsGroupedByDate()
                if grouped.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "기록 없음",
                            systemImage: "clock.arrow.circlepath",
                            description: Text("집중 세션을 시작하면 여기에 기록됩니다.")
                        )
                    }
                } else {
                    ForEach(grouped, id: \.date) { group in
                        Section(header: Text(formatDate(group.date))) {
                            ForEach(group.sessions) { session in
                                sessionRow(session)
                            }
                        }
                    }
                }
            }
            .navigationTitle("기록")
            .refreshable {
                await viewModel.history.refreshFromCloud()
            }
            .task {
                await viewModel.history.refreshFromCloud()
            }
        }
    }

    // MARK: - Weekly Summary

    private var weeklySummaryCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "book.fill")
                    .foregroundStyle(.blue)
                Text("공부")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatHours(viewModel.history.weeklyStudyTime))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 60)

            VStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(.orange)
                Text("업무")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatHours(viewModel.history.weeklyWorkTime))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Session Row

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.iconName)
                .foregroundStyle(session.sessionType == .study ? .blue : .orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.sessionType.displayName)
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 4) {
                    Text(formatTime(session.startTime))
                    if let endTime = session.endTime {
                        Text("~")
                        Text(formatTime(endTime))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.formattedDuration)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Formatting

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "오늘"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        }
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatHours(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        }
        return "\(minutes)분"
    }
}
