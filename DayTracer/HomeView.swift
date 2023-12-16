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
        let now = Date()
        self.dayProgress = ProgressCalculators.calculateDayProgress(for: now)
        self.yearProgress = ProgressCalculators.calculateYearProgress(for: now)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView { // スクロールビューを追加
                VStack(spacing: 20) { // 要素間のスペースを設定
                    
                    Section {
                        Text(Date(), style: .date)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .padding(.bottom, 5) // 日付の下のスペース
                        Divider() // 区切り線を追加
                        }
                    
                    Section {
                        // 時間表示
                        Text(currentTime)
                            .font(.system(size: 55, weight: .bold, design: .monospaced))
                            .padding(.bottom, 5) // 時間の下のスペース
                            .onReceive(timer) { _ in
                                self.currentTime = timeFormatter.string(from: Date())
                            }
                        Divider() // 区切り線を追加
                    }
                    // 年間進捗セクション
                    Section {
                        CustomLinearProgressView(progress: yearProgress, color: .blue)
                            .frame(height: 20)
                            .padding(.bottom, 5) // プログレスバーの下のスペース
                        Text(String(format: "%.8f%%", yearProgress * 100))
                            .font(.system(.title2, design: .monospaced)).fontWeight(.bold)
                        Divider() // 区切り線を追加
                    }

                    // 本日の進捗セクション
                    Section {
                        ZStack{
                            CustomCircleProgressView(progress: dayProgress, color: .blue, size: 100)
                            Text("\(dayProgress * 100, specifier: "%.4f")%")
                                .font(.system(size: 20, weight: .bold, design: .default))
                        }
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
        }.background(Color.gray)
        }
}

