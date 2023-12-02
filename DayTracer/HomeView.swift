//
//  HomeView.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//


import SwiftUI


struct HomeView: View {
    @State private var dayProgress: Double = 0
    @State private var yearProgress: Double = 0
    @State private var currentTime: String = ""
    let timeFormatter: DateFormatter
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    init() {
            timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .medium // This includes hours, minutes, and seconds
        }

    func updateProgress() {
        self.dayProgress = calculateDayProgress()
        self.yearProgress = calculateYearProgress()
    }
    // 年間の進捗を計算するヘルパーメソッド
    func calculateYearProgress() -> Double {
        let now = Date()
        let yearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: now))!
        let yearEnd = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.date(byAdding: .year, value: 1, to: yearStart)!))!
        let totalSeconds = yearEnd.timeIntervalSince(yearStart)
        let elapsedSeconds = now.timeIntervalSince(yearStart)
        return elapsedSeconds / totalSeconds
    }
    
    // 本日の進捗を計算するヘルパーメソッド
    func calculateDayProgress() -> Double {
            let now = Date()
            let startOfDay = Calendar.current.startOfDay(for: now)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            let totalSeconds = endOfDay.timeIntervalSince(startOfDay)
            let elapsedSeconds = now.timeIntervalSince(startOfDay)
            return elapsedSeconds / totalSeconds
        }
    
    
    var body: some View {
        NavigationView {
            ScrollView { // スクロールビューを追加
                VStack(spacing: 20) { // 要素間のスペースを設定
                    Text(Date(), style: .date)
                                    .font(.system(size: 30, weight: .black, design: .rounded))
                    
                    Text(currentTime)
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .onReceive(timer) { _ in
                        self.currentTime = timeFormatter.string(from: Date())
                    }
                    
                    Group {
                        VStack {

                            Text("Year Progress")
                                                .font(.system(size: 20, weight: .semibold, design: .default))
                            CustomLinearProgressView(progress: yearProgress, color: .blue)
                                            .frame(height: 20)
                            Text(String(format: "%.8f%%", yearProgress * 100))
                                .font(.system(.title2, design: .monospaced)).fontWeight(.bold)
                            
                        }
                    }
                    
                    Group {
                        Text("Today's Progress")
                            .font(.headline)
                        CustomCircleProgressView(progress: $dayProgress, color: .blue)
                    }
                }
                .onAppear {
                    self.updateProgress()
                    self.currentTime = timeFormatter.string(from: Date())
                }
                .onReceive(timer) { _ in
                    self.updateProgress()
                }
                .padding()
            }
            .navigationTitle("DayTracer") // ナビゲーションバーにタイトルを設定
            .navigationBarTitleDisplayMode(.inline).toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logoImage") // ロゴ画像
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40) // 適切なサイズに調整
                }
            }
            
        }
        }
}

//線型プログレスパー表示
struct CustomLinearProgressView: View {
    var progress: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().frame(width: geometry.size.width, height: 20)
                    .foregroundColor(Color(UIColor.systemGray3))
                    .opacity(0.3)
                
                Capsule().frame(width: CGFloat(progress) * geometry.size.width, height: 20)
                    .foregroundColor(color)
                    .animation(.linear, value: progress)
            }
        }
        .cornerRadius(10) // This ensures the background capsule has rounded corners too
    }
}

//円形プログレスパー表示
struct CustomCircleProgressView: View {
    @Binding var progress: Double
    var color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(Color(UIColor.systemGray5))
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round)) // This will create rounded edges
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
            Text("\(progress * 100, specifier: "%.4f")%")
                .font(.system(size: 20, weight: .bold, design: .default))
        }
        .frame(width: 150, height: 150)
    }
}
