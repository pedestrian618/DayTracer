import SwiftUI

struct HomeView: View {
    @State private var dayProgress: Double = 0
    @State private var weekProgress: Double = 0
    @State private var monthProgress: Double = 0
    @State private var yearProgress: Double = 0
    @State private var currentTime: String = ""
    @State private var seconds: String = ""
    @State private var latestEntries: [DiaryEntry] = []

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private static let secondsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ss" // 秒のみ
        return formatter
    }()

    /// 時計表示（時:分）。時刻形式の設定に従い 24時間/12時間を切り替える。
    private static func clockString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = (AppSettings.timeFormat == .twentyFour) ? "H:mm" : "h:mm"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    progressGrid
                    notesSection
                }
                .onAppear {
                    updateProgress()
                    updateTime()
                    loadLatestEntries()
                }
                .onReceive(timer) { _ in
                    updateProgress()
                    updateTime()
                }
                .padding()
            }
            .navigationTitle("DayTracer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logoImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 日付：主役の時刻を引き立てる「脇役」。1行・控えめな色に。
            Text(AppSettings.dateString(from: Date()))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(alignment: .center, spacing: 16) {
                // 時刻：このヘッダーの主役。秒は青をやめ、控えめな添え字に。
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(currentTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text(seconds)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }

                Spacer()

                // 今日の進捗：唯一の青アクセント。小数3桁＋等幅数字で
                // 桁幅が揺れず、最後の桁がほぼ毎秒なめらかに進む。
                VStack(spacing: 4) {
                    ZStack {
                        CustomCircleProgressGradientView(progress: dayProgress, gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), size: 78)
                        Text(String(format: "%.3f%%", dayProgress * 100))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.horizontal, 2)
                    }
                    Text("Today")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 5, y: 2) // light mode でも「カード」と分かる控えめな影
        )
    }

    private var progressGrid: some View {
        VStack(spacing: 20) {
            progressBarSection(title: "Week Progress", progress: weekProgress, color: Color.blue.opacity(0.75))
            progressBarSection(title: "Month Progress", progress: monthProgress, color: Color.blue.opacity(0.5))
            progressBarSection(title: "Year Progress", progress: yearProgress, color: .blue)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Latest Notes")
                .font(.headline)
                .padding(.bottom, 5)

            if latestEntries.isEmpty {
                Text("まだノートがありません")
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(latestEntries) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.text)
                            .font(.body)
                        Text(entry.date.formatted())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
            }
        }
        .padding(.horizontal)
    }

    private func progressBarSection(title: String, progress: Double, color: Color) -> some View {
        ZStack(alignment: .center) {
            CustomLinearProgressGradientView(progress: progress, gradient: Gradient(colors: [color.opacity(0.5), color]))
                .frame(height: 20)
            Text("\(title): \(String(format: "%.0f%%", progress * 100))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(height: 20, alignment: .center)
        }
        .padding(.horizontal)
    }

    private func updateProgress() {
        let now = Date()
        dayProgress = ProgressCalculators.calculateDayProgress(for: now)
        weekProgress = ProgressCalculators.calculateWeekProgress(for: now, calendar: AppSettings.calendar)
        monthProgress = ProgressCalculators.calculateMonthProgress(for: now)
        yearProgress = ProgressCalculators.calculateYearProgress(for: now)
    }

    private func updateTime() {
        let now = Date()
        currentTime = HomeView.clockString(now)
        seconds = HomeView.secondsFormatter.string(from: now)
    }

    private func loadLatestEntries() {
        DiaryRepository().fetchLatest(limit: 3) { result in
            switch result {
            case .success(let entries):
                latestEntries = entries
            case .failure:
                latestEntries = []
            }
        }
    }
}
