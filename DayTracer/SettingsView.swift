//
//  SettingsView.swift
//  DayTracer
//
//  Created by murate on 2023/12/03.
//


import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase
import GoogleSignIn
import WidgetKit

struct SettingsView: View {
    @ObservedObject var authManager = AuthenticationManager.shared

    @AppStorage(AppSettings.Keys.weekStart, store: SharedConfig.defaults) private var weekStart: WeekStart = .system
    @AppStorage(AppSettings.Keys.timeFormat, store: SharedConfig.defaults) private var timeFormat: TimeFormatOption = .system
    @AppStorage(AppSettings.Keys.dateStyle, store: SharedConfig.defaults) private var dateStyle: DateStyleOption = .system

    // 活動時間（日バーの窓）。開始時刻＋長さ で保持し、end - start <= 24h を構造的に保証する。
    @AppStorage(AppSettings.Keys.dayStartMinutes, store: SharedConfig.defaults) private var dayStartMinutes: Int = AppSettings.defaultDayStartMinutes
    @AppStorage(AppSettings.Keys.dayEndMinutes, store: SharedConfig.defaults) private var dayEndMinutes: Int = AppSettings.defaultDayEndMinutes

    /// 開始時刻の DatePicker 用バインディング（分数 ⇄ Date）。長さは維持する。
    private var startTimeBinding: Binding<Date> {
        Binding(
            get: {
                let base = Calendar.current.startOfDay(for: Date())
                return Calendar.current.date(byAdding: .minute, value: dayStartMinutes, to: base) ?? base
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                let newStart = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
                let length = dayEndMinutes - dayStartMinutes
                dayStartMinutes = newStart
                dayEndMinutes = newStart + length
            }
        )
    }

    /// 1日の長さ（時間）用バインディング。終了 = 開始 + 長さ。
    private var dayLengthHoursBinding: Binding<Int> {
        Binding(
            get: { max(1, min(24, (dayEndMinutes - dayStartMinutes) / 60)) },
            set: { hours in dayEndMinutes = dayStartMinutes + hours * 60 }
        )
    }

    /// 計算した終了時刻のキャプション（翌日跨ぎ・24:00 を明示）。
    private var endTimeCaption: String {
        let end = dayEndMinutes
        let h = (end / 60) % 24
        let m = end % 60
        let time = String(format: "%02d:%02d", h, m)
        if end == 1440 { return "終了 24:00（当日いっぱい）" }
        if end > 1440 { return "終了 翌 \(time)" }
        return "終了 \(time)"
    }

    var body: some View {
        NavigationStack {
            List {
                if authManager.isSignedIn {
                    // User is signed in
                    Section(header: Text("User Info")) {
                        NavigationLink(destination: UserSettingsView()) {
                            HStack {
                                ProfileImageView(url: authManager.userProfilePictureURL)
                                Text(authManager.userName ?? "Unknown")
                            }
                        }
                    }
                } else {
                    // User is not signed in
                    Section(header: Text("User Info")) {
                        NavigationLink(destination: LoginView()) {
                            Text("Unknown")
                        }
                    }
                }

                // 表示設定（アプリ・ウィジェット共通）
                Section(header: Text("表示 / Display")) {
                    Picker("週の始まり", selection: $weekStart) {
                        ForEach(WeekStart.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("時刻の表示", selection: $timeFormat) {
                        ForEach(TimeFormatOption.allCases) { Text($0.label).tag($0) }
                    }
                    Picker("日付の表示", selection: $dateStyle) {
                        ForEach(DateStyleOption.allCases) { Text($0.label).tag($0) }
                    }
                }

                // 活動時間（日バーの起点・長さ）。デフォルト 0:00・24時間 = 従来挙動。
                Section {
                    DatePicker("1日の開始", selection: startTimeBinding, displayedComponents: .hourAndMinute)
                    Picker("1日の長さ", selection: dayLengthHoursBinding) {
                        ForEach(1...24, id: \.self) { Text("\($0) 時間").tag($0) }
                    }
                } header: {
                    Text("活動時間 / Active hours")
                } footer: {
                    Text("\(endTimeCaption)。日の進捗バーはこの時間帯で 0→100% に進みます（終了後は次の開始まで 100%）。週・月・年の進捗には影響しません。")
                }
            }
            .navigationTitle("Settings")
            .onChange(of: weekStart) { _, _ in reloadWidgets() }
            .onChange(of: timeFormat) { _, _ in reloadWidgets() }
            .onChange(of: dateStyle) { _, _ in reloadWidgets() }
            .onChange(of: dayStartMinutes) { _, _ in reloadWidgets() }
            .onChange(of: dayEndMinutes) { _, _ in reloadWidgets() }
        }
    }

    /// 設定変更をウィジェットへ反映する。
    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct LoginView: View {
    @ObservedObject var authManager = AuthenticationManager.shared

    var body: some View {
        VStack {
            Text("Sign in to continue")
            Button("Sign in with Google") {
                authManager.googleAuth()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
        }.navigationTitle("User Settings")
    }
}

struct UserSettingsView: View {
    @ObservedObject var authManager = AuthenticationManager.shared

    var body: some View {
        Form {
            if let email = authManager.userEmail {
                Section(header: Text("Email")) {
                    Text(email)
                }
            }

            Section {
                Button("Sign Out") {
                    authManager.signOut()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("User Settings")
    }
}

struct ProfileImageView: View {
    let url: URL?

    var body: some View {
        if let url = url {
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
    }
}
