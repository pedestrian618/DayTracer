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
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading) {
                Text(AppSettings.dateString(from: Date()))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                HStack(alignment: .bottom, spacing: 4) {
                    Text(currentTime)
                        .font(.system(size: 45, weight: .bold, design: .monospaced))
                    Text(seconds)
                        .font(.system(size: 30, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .offset(y: -5) // 少し上に配置
                }
            }
            Spacer()
            ZStack {
                CustomCircleProgressGradientView(progress: dayProgress, gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), size: 85)
                Text(String(format: "%.2f%%", dayProgress * 100))
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .padding()
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
            Text("\(title): \(String(format: "%.2f%%", progress * 100))")
                .font(.system(size: 14, weight: .bold, design: .default))
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
