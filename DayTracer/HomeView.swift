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
    @State private var monthProgress: Double = 0
    @State private var currentTime: String = ""
    
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateSection
                    timeSection
                    yearProgressSection
                    dayProgressSection
                    monthProgressSection
                }
                .onAppear {
                    updateProgress()
                    updateTime()
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
        .background(Color.gray)
    }
    
    private var dateSection: some View {
        Section {
            Text(Date(), style: .date)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.bottom, 5)
            Divider()
        }
    }
    
    private var timeSection: some View {
        Section {
            Text(currentTime)
                .font(.system(size: 55, weight: .bold, design: .rounded))
                .padding(.bottom, 5)
            Divider()
        }
    }
    
    private var yearProgressSection: some View {
        Section {
            CustomLinearProgressView(progress: yearProgress, color: .blue)
                .frame(height: 20)
                .padding(.bottom, 5)
            CustomLinearProgressGradientView(progress: yearProgress, gradient: Gradient(colors: [.blue, .purple]))
                .frame(height: 20)
            Text(String(format: "%.8f%%", yearProgress * 100))
                .font(.system(.title2, design: .monospaced))
                .fontWeight(.bold)
            Divider()
        }
    }
    
    private var dayProgressSection: some View {
        Section {
            ZStack {
                CustomCircleProgressView(progress: dayProgress, color: .blue, size: 100)
                Text(String(format: "%.4f%%", dayProgress * 100))
                    .font(.system(size: 20, weight: .bold))
            }
            CustomCircleProgressGradientView(progress: dayProgress, gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), size: 100)
        }
    }
    
    private var monthProgressSection: some View {
        Section {
            CustomLinearProgressGradientView(progress: monthProgress, gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]))
                .frame(height: 20)
        }
    }
    
    private func updateProgress() {
        let now = Date()
        dayProgress = ProgressCalculators.calculateDayProgress(for: now)
        yearProgress = ProgressCalculators.calculateYearProgress(for: now)
        monthProgress = ProgressCalculators.calculateMonthProgress(for: now)
    }
    
    private func updateTime() {
        currentTime = HomeView.timeFormatter.string(from: Date())
    }
}

