//
//  DayTracerApp.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
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

    return true
  }
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
}

@main
struct DayTracerApp: App {
    // 追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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
                if showWelcomeScreen {
                    WelcomeView(showWelcomeScreen: $showWelcomeScreen)
                } else {
                    ContentView()
                }
            }
        }
}

//import SwiftUI
//import SwiftData
//import FirebaseCore
//import GoogleSignIn
//import os
//
//class GlobalState {
//    static let shared = GlobalState()
//    var selectedTab: Int = 0
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//
//    return true
//  }
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
//        if GIDSignIn.sharedInstance.handle(url) {
//            return true
//        }
//        // カスタムURLスキームの処理
//        if url.scheme == "daytracer" && url.host == "notes" {
//            // ここで`NotesView`を表示するロジックを実装
//            // 処理が正常に行われた場合はtrueを返す
//            // `NotesView`を表示するためにselectedTabを更新
//            GlobalState.shared.selectedTab = 1
//            return true
//        }
//        // どの処理にも一致しない場合はfalseを返す
//        return false
//    }
//}
//
//@main
//struct DayTracerApp: App {
//    // 追加
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @State private var selectedTab: Int = 0
//    @State private var showWelcomeScreen = true
//    
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//            WindowGroup {
//                if showWelcomeScreen {
//                    WelcomeView(showWelcomeScreen: $showWelcomeScreen)
//                } else {
//                    ContentView(selectedTab: Binding(get: { GlobalState.shared.selectedTab },
//                        set: { GlobalState.shared.selectedTab = $0 }))
//                }
//            }
//        }
//}
