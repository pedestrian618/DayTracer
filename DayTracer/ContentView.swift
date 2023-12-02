//
//  ContentView.swift
//  DayTracer
//
//  Created by murate on 2023/11/19.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor(named: "DayTracerBlue")?.withAlphaComponent(0.5)
            UITabBar.appearance().isTranslucent = true
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        }
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "book")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}










struct SettingsView: View {
    // 設定画面の状態や動作をここに定義する
    var body: some View {
        // 設定項目を表示するコード
        Text("Settings Screen")
    }
}
#Preview {
    ContentView()
    .modelContainer(for: Item.self, inMemory: true)}
