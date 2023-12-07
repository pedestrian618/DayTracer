//
//  WelcomeView.swift
//  DayTracer
//
//  Created by murate on 2023/12/03.
//

import SwiftUI
import SwiftData

struct WelcomeView: View {
    @Binding var showWelcomeScreen: Bool
    @State private var opacity = 1.0 // 初期の透明度は1.0（完全に不透明）

    var body: some View {
        ZStack {
            Image("welcomeImage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
        .opacity(opacity) // 透明度を適用
        .onAppear {
            // 2秒後にフェードアウト開始
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0 // 透明度を0にしてフェードアウト
                }
                // フェードアウト後にウェルカム画面を閉じる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showWelcomeScreen = false
                }
            }
        }
    }
}

