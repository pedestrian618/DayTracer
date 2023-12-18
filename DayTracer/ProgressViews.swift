//
//  ProgressViews.swift
//  DayTracer
//
//  Created by murate on 2023/12/10.
//

import SwiftUI

//線型プログレスパー表示
struct CustomLinearProgressView: View {
    var progress: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().frame(width: geometry.size.width, height: 20)
                    .foregroundColor(Color(UIColor.systemGray5))
                    .opacity(0.3)
                
                Capsule().frame(width: CGFloat(progress) * geometry.size.width, height: 20)
                    .foregroundColor(color)
                    .animation(.linear, value: progress)
            }
        }
        .cornerRadius(10) // This ensures the background capsule has rounded corners too
    }
}

//円形プログレスパー表示
struct CustomCircleProgressView: View {
    var progress: Double // @Binding を削除しました
    var color: Color
    var size: CGFloat // サイズを調整するための新しいパラメータ

    var body: some View {
        ZStack {
//            Circle()
//                .stroke(lineWidth: size * 0.1)
//                .foregroundColor(Color(UIColor.systemGray5))
//                .shadow(color: .white, radius: size * 0.02, x: size * -0.02, y: size * -0.02)
//                .shadow(color: .white, radius: size * 0.02, x: size * 0.02, y: size * 0.02)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
        }
        .frame(width: size, height: size) 
    }
}


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
                    .foregroundColor(Color.clear) // 前景色をクリアに設定
                    .background(
                        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing) // グラデーションを背景に設定
                    )
                    .mask(Capsule()) // カプセル形状にマスクを適用
                    .animation(Animation.linear(duration: 0.2), value: progress)
            }
        }
        .cornerRadius(10) // 角丸の半径を設定（不要な場合は削除しても良い）
    }
}

//グラデーション円形プログレスパー表示
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
                            // アニメーションを適用する場合は、以下の行をコメントアウト解除
                            // .animation(.linear, value: progress)
        }
        .frame(width: size, height: size)
    }
}
//円形プログレスパー表示
//struct CustomCircleProgressView: View {
//    @Binding var progress: Double
//    var color: Color
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .stroke(lineWidth: 20)
//                .opacity(0.3)
//                .foregroundColor(Color(UIColor.systemGray5))
//            Circle()
//                .trim(from: 0, to: CGFloat(progress))
//                .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round)) // This will create rounded edges
//                .rotationEffect(Angle(degrees: -90))
//                .animation(.linear, value: progress)
//            Text("\(progress * 100, specifier: "%.4f")%")
//                .font(.system(size: 20, weight: .bold, design: .default))
//        }
//        .frame(width: 150, height: 150)
//    }
//}
