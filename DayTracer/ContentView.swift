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
        // 計器盤の世界観としてアプリ全体をダーク固定。差し色（アンバー）を唯一のアクセントにする。
        .preferredColorScheme(.dark)
        .tint(DS.Colors.remaining)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
        .modelContainer(for: DiaryRecord.self, inMemory: true)
}
