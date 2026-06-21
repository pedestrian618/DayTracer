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
            }
            .navigationTitle("Settings")
            .onChange(of: weekStart) { _, _ in reloadWidgets() }
            .onChange(of: timeFormat) { _, _ in reloadWidgets() }
            .onChange(of: dateStyle) { _, _ in reloadWidgets() }
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
