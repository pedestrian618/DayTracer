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
            Circle()
                .stroke(lineWidth: size * 0.1)
                .foregroundColor(Color(UIColor.systemGray5))
                .shadow(color: .white, radius: size * 0.02, x: size * -0.02, y: size * -0.02)
                .shadow(color: .white, radius: size * 0.02, x: size * 0.02, y: size * 0.02)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
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
