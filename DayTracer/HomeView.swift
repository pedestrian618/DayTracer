import SwiftUI

/// ホーム = 「残り時間の計器盤」。
/// 主役は年の残り%（小数6桁・常時駆動）。日/週/月は残量バー、下部に365日グリッドと使途記録。
struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var latestEntries: [DiaryEntry] = []
    /// 今年の記録済み日（通算日）の集合。年間グリッドの塗り分けに使う。
    @State private var recordedDays: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DS.Metrics.spacingLarge) {
                // 時計は DateFormatter を使うため1秒周期、数字とバーは数式のみなので
                // 約20fpsで常時駆動。グリッドや記録一覧は毎フレーム再描画しない。
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    header(now: context.date)
                }
                TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { context in
                    VStack(alignment: .leading, spacing: DS.Metrics.spacingLarge) {
                        heroSection(now: context.date)
                        drainBars(now: context.date)
                    }
                }
                yearGridSection
                logSection
            }
            .padding(DS.Metrics.screenPadding)
        }
        .background(DS.Colors.panel.ignoresSafeArea())
        .onAppear(perform: loadEntries)
    }

    private func header(now: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("DAYTRACER")
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
                    .tracking(3)
                Spacer()
                Text(AppSettings.dateString(from: now))
                    .font(DS.Fonts.date)
                    .foregroundStyle(DS.Colors.label)
            }
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(HomeView.clockString(now))
                    .font(DS.Fonts.clock)
                    .foregroundStyle(DS.Colors.numeral)
                Text(HomeView.secondsFormatter.string(from: now))
                    .font(DS.Fonts.clockSeconds)
                    .foregroundStyle(DS.Colors.remaining)
            }
        }
    }

    private func heroSection(now: Date) -> some View {
        let yearRemaining = (1 - ProgressCalculators.calculateYearProgress(for: now)) * 100
        let remaining = ProgressCalculators.remainingTimeOfYear(for: now)
        return VStack(alignment: .leading, spacing: 6) {
            Text("YEAR — 残り")
                .font(DS.Fonts.sectionLabel)
                .foregroundStyle(DS.Colors.label)
                .tracking(2)
            Text(String(format: "%.6f%%", yearRemaining))
                .font(DS.Fonts.hero)
                .foregroundStyle(DS.Colors.remaining)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(String(format: "残り %d日 %02d:%02d:%02d",
                        remaining.days, remaining.hours, remaining.minutes, remaining.seconds))
                .font(DS.Fonts.countdown)
                .foregroundStyle(DS.Colors.numeral)
            DrainBarView(progress: ProgressCalculators.calculateYearProgress(for: now))
                .frame(height: DS.Metrics.barHeight)
        }
    }

    private func drainBars(now: Date) -> some View {
        VStack(spacing: DS.Metrics.spacing) {
            drainRow(label: "DAY",
                     progress: ProgressCalculators.calculateDayProgress(for: now))
            drainRow(label: "WEEK",
                     progress: ProgressCalculators.calculateWeekProgress(for: now, calendar: AppSettings.calendar))
            drainRow(label: "MONTH",
                     progress: ProgressCalculators.calculateMonthProgress(for: now))
        }
    }

    private func drainRow(label: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
                    .tracking(2)
                Spacer()
                Text(String(format: "残り %.4f%%", (1 - progress) * 100))
                    .font(DS.Fonts.barValue)
                    .foregroundStyle(DS.Colors.numeral)
            }
            DrainBarView(progress: progress)
                .frame(height: DS.Metrics.barHeightThin)
        }
    }

    // MARK: - 年間グリッド（365日）

    private var yearGridSection: some View {
        let now = Date()
        let today = ProgressCalculators.dayOfYear(for: now)
        let total = ProgressCalculators.daysInYear(for: now)
        let recordedCount = recordedDays.filter { $0 <= today }.count
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: DS.Metrics.yearGridGap),
            count: DS.Metrics.yearGridColumns
        )
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("YEAR IN DAYS")
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
                    .tracking(2)
                Spacer()
                Text("記録 \(recordedCount)/\(today)日")
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
            }
            LazyVGrid(columns: columns, spacing: DS.Metrics.yearGridGap) {
                ForEach(1...total, id: \.self) { day in
                    dayCell(day: day, today: today)
                }
            }
            HStack(spacing: 12) {
                legend(color: DS.Colors.remaining, text: "記録した日")
                legend(color: DS.Colors.spent, text: "過ぎた日")
                legend(color: .clear, text: "これから", stroke: true)
            }
        }
    }

    private func dayCell(day: Int, today: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: 1.5)
        return Group {
            if day == today {
                shape.fill(DS.Colors.numeral)
            } else if day > today {
                shape.strokeBorder(DS.Colors.line, lineWidth: 0.5)
            } else if recordedDays.contains(day) {
                shape.fill(DS.Colors.remaining.opacity(0.85))
            } else {
                shape.fill(DS.Colors.spent)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func legend(color: Color, text: String, stroke: Bool = false) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(color)
                .overlay {
                    if stroke {
                        RoundedRectangle(cornerRadius: 1.5).strokeBorder(DS.Colors.line, lineWidth: 0.5)
                    }
                }
                .frame(width: 8, height: 8)
            Text(text)
                .font(DS.Fonts.caption)
                .foregroundStyle(DS.Colors.label)
        }
    }

    // MARK: - 使途記録

    private var logSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("使途記録")
                    .font(DS.Fonts.sectionLabel)
                    .foregroundStyle(DS.Colors.label)
                    .tracking(2)
                Spacer()
                Button {
                    router.selectedTab = .notes
                } label: {
                    Text("記録する")
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.remaining)
                }
            }

            if latestEntries.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("まだ記録がありません")
                        .font(DS.Fonts.body)
                        .foregroundStyle(DS.Colors.numeral)
                    Text(String(format: "今日は年の%.2f%%。何に使った？",
                                ProgressCalculators.dayWeightOfYear(for: Date()) * 100))
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.label)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DS.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Metrics.cardCorner))
            } else {
                ForEach(latestEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.text)
                            .font(DS.Fonts.body)
                            .foregroundStyle(DS.Colors.numeral)
                        HStack {
                            Text(AppSettings.dateString(from: entry.date))
                            Spacer()
                            Text(String(format: "= 年の%.2f%%",
                                        ProgressCalculators.dayWeightOfYear(for: entry.date) * 100))
                        }
                        .font(DS.Fonts.caption)
                        .foregroundStyle(DS.Colors.label)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DS.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Metrics.cardCorner))
                }
            }
        }
    }

    // MARK: - データ・整形

    private static let secondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss"
        return formatter
    }()

    /// 時計表示（時:分）。時刻形式の設定に従い 24時間/12時間を切り替える。
    private static func clockString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (AppSettings.timeFormat == .twentyFour) ? "H:mm" : "h:mm"
        return formatter.string(from: date)
    }

    private func loadEntries() {
        // 最新3件は使途記録の一覧に、全件の日付は年間グリッドの塗りに使う。
        DiaryRepository().fetchLatest { result in
            guard case .success(let entries) = result else {
                latestEntries = []
                recordedDays = []
                return
            }
            latestEntries = Array(entries.prefix(3))
            let calendar = Calendar.current
            let thisYear = calendar.component(.year, from: Date())
            recordedDays = Set(
                entries.lazy
                    .filter { calendar.component(.year, from: $0.date) == thisYear }
                    .map { ProgressCalculators.dayOfYear(for: $0.date) }
            )
        }
    }
}
