//
//  ContentView.swift
//  DayTracer
//
//  Created by murate on 2023/11/19.
//

import SwiftUI
import SwiftData

/// アプリ内のタブ遷移を司るルーター。ディープリンク（daytracer://notes）からも操作する。
final class AppRouter: ObservableObject {
    enum Tab: Hashable { case home, notes, settings }
    @Published var selectedTab: Tab = .home
}

struct ContentView: View {
    @EnvironmentObject private var router: AppRouter

    init() {
        // Customizing navigation and tab bars to match the blue theme of the app icon
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "DayTracerBlue") // Custom blue color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Set navigation and tab bars to be translucent with blur effect
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor(named: "DayTracerBlue")?.withAlphaComponent(0.5)
        UITabBar.appearance().isTranslucent = true
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppRouter.Tab.home)

            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "book")
                }
                .tag(AppRouter.Tab.notes)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppRouter.Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
        .modelContainer(for: Item.self, inMemory: true)
}
