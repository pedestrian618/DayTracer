//
//  ContentView.swift
//  DayTracer
//
//  Created by murate on 2023/11/19.
//

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
            UINavigationBar.appearance().tintColor = .white
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







#Preview {
    ContentView()
    .modelContainer(for: Item.self, inMemory: true)}

//import SwiftUI
//import SwiftData
//
//struct ContentView: View {
//    @Binding var selectedTab: Int
//    init(selectedTab: Binding<Int>) {
//            // Customizing navigation and tab bars to match the blue theme of the app icon
//            self._selectedTab = selectedTab
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = UIColor(named: "DayTracerBlue") // Custom blue color
//            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//
//            // Set navigation and tab bars to be translucent with blur effect
//            UINavigationBar.appearance().standardAppearance = appearance
//            UINavigationBar.appearance().compactAppearance = appearance
//            UINavigationBar.appearance().scrollEdgeAppearance = appearance
//            UINavigationBar.appearance().tintColor = .white
//            UITabBar.appearance().backgroundImage = UIImage()
//            UITabBar.appearance().shadowImage = UIImage()
//            UITabBar.appearance().backgroundColor = UIColor(named: "DayTracerBlue")?.withAlphaComponent(0.5)
//            UITabBar.appearance().isTranslucent = true
//            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
//            
//        }
//    var body: some View {
// 
//        TabView(selection: $selectedTab) {
//                HomeView()
//                    .tabItem {
//                        Label("Home", systemImage: "house")
//                    }
//                    .tag(0)
//                
//                NotesView()
//                    .tabItem {
//                        Label("Notes", systemImage: "book")
//                    }
//                    .tag(1)
//                
//                SettingsView()
//                    .tabItem {
//                        Label("Settings", systemImage: "gear")
//                    }
//                    .tag(2)
//            }
//    }
//}
//
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(selectedTab: .constant(0))
//            .modelContainer(for: Item.self, inMemory: true)
//    }
//}
//
//
