//
//  ProgressViews.swift
//  DayTracer
//
//  Created by murate on 2023/12/10.
//

import SwiftUI

/// グラデーション付きの線形プログレスバー
struct CustomLinearProgressGradientView: View {
    var progress: Double // 0.0 ~ 1.0 の範囲でプログレスを表す
    var gradient: Gradient // グラデーションを表すプロパティ

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景のカプセル
                Capsule().frame(width: geometry.size.width, height: 20)
                    .foregroundColor(Color(UIColor.systemGray3))
                    .opacity(0.3)

                // プログレスを表示するカプセル
                Capsule().frame(width: CGFloat(progress) * geometry.size.width, height: 20)
                    .foregroundColor(Color.clear)
                    .background(
                        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                    )
                    .mask(Capsule())
                    .animation(Animation.linear(duration: 0.2), value: progress)
            }
        }
        .cornerRadius(10)
    }
}

/// グラデーション付きの円形プログレスバー
struct CustomCircleProgressGradientView: View {
    var progress: Double
    var gradient: Gradient // グラデーションを表すプロパティ
    var size: CGFloat

    var body: some View {
        ZStack {
            // 背景の円
            Circle()
                .stroke(lineWidth: size * 0.1)
                .foregroundColor(Color(UIColor.systemGray5))

            // プログレスの円
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    AngularGradient(
                        gradient: gradient,
                        center: .center,
                        startAngle: .degrees(0), // 始点の角度を0度に設定
                        endAngle: .degrees(360 * progress) // 終点の角度を動的に設定
                    ),
                    style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90)) // 12時の位置から始める
        }
        .frame(width: size, height: size)
    }
}
