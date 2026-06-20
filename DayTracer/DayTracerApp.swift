//
//  DayTracerApp.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        _ = AuthenticationManager.shared // 認証状態の監視を起動時から有効化する
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct DayTracerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var router = AppRouter()
    @State private var showWelcomeScreen = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
    }

    /// ウィジェット等からの daytracer://notes を受けて Notes タブを開く。
    /// （Google サインインのコールバックは AppDelegate 側で処理されるため scheme で振り分ける）
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "daytracer" else { return }
        if url.host == "notes" {
            showWelcomeScreen = false
            router.selectedTab = .notes
        }
    }
}
