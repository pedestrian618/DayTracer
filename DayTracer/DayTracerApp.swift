//
//  DayTracerApp.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//

import SwiftUI
import SwiftData

@main
struct DayTracerApp: App {
    @StateObject private var router = AppRouter()
    @State private var showWelcomeScreen = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DiaryRecord.self,
        ])
        // CloudKit 同期（private database）。未サインイン端末ではローカル保存として動き、
        // サインインすれば自動で同期される。コンテナ ID は entitlements と一致させること。
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.junkyfly.DayTracer")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if showWelcomeScreen {
                    WelcomeView(showWelcomeScreen: $showWelcomeScreen)
                } else {
                    ContentView()
                }
            }
            .environmentObject(router)
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
        .modelContainer(sharedModelContainer)
    }

    /// ウィジェット等からの daytracer://notes を受けて Notes タブを開く。
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "daytracer" else { return }
        if url.host == "notes" {
            showWelcomeScreen = false
            router.selectedTab = .notes
        }
    }
}
