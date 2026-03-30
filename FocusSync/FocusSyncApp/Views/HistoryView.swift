import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var vm: FocusViewModel

    var body: some View {
        NavigationStack {
            List {
                // 이번 주 요약
                Section("이번 주 요약") {
                    HStack(spacing: 20) {
                        weekStat(icon: "book.fill", label: "공부",
                                 time: vm.store.weeklyStudyTime, color: .blue)
                        Divider().frame(height: 60)
                        weekStat(icon: "briefcase.fill", label: "업무",
                                 time: vm.store.weeklyWorkTime, color: .orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }

                // 날짜별 기록
                let grouped = vm.store.sessionsGroupedByDate()
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
        }
    }

    private func weekStat(icon: String, label: String, time: TimeInterval, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(color)
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(formatHours(time))
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: 12) {
            Image(systemName: session.sessionType.iconName)
                .foregroundStyle(session.sessionType == .study ? .blue : .orange)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(session.sessionType.displayName)
                        .font(.subheadline.weight(.medium))
                    Text(session.deviceName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(.systemGray5)))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Text(formatTime(session.startTime))
                    if let end = session.endTime {
                        Text("~")
                        Text(formatTime(end))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.formattedDuration)
                .font(.subheadline.weight(.medium))
        }
        .padding(.vertical, 2)
    }

    // MARK: - Formatting

    private func formatDate(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "오늘" }
        if cal.isDateInYesterday(date) { return "어제" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func formatHours(_ t: TimeInterval) -> String {
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        return h > 0 ? "\(h)시간 \(m)분" : "\(m)분"
    }
}
