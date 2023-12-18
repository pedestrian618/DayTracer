//
//  DayTracerSmallView.swift
//  DayTracer
//
//  Created by murate on 2023/12/10.
//

import WidgetKit
import SwiftUI

struct DayTracerWidgetsSmallView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            // Smallサイズのウィジェットに適したコンテンツ
            ZStack {
                CustomCircleProgressGradientView(progress: entry.dayProgress, gradient: Gradient(colors: [entry.selectedSubColor.opacity(0.55), entry.selectedColor]),size: 75)
                Text("\(Int(entry.dayProgress * 100))%")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .frame(height: 20, alignment: .center)
            }
            .padding(.bottom, 10)
            // 年間の進捗を表示する線形プログレスバー
            ZStack(alignment: .center) { // ZStackに中央揃えを指定
                CustomLinearProgressGradientView(progress: entry.yearProgress, gradient: Gradient(colors: [entry.selectedSubColor.opacity(0.55), entry.selectedColor]))
                    .frame(height: 20) // プログレスバーの高さを指定
                
                Text(" \(entry.yearProgress * 100, specifier: "%.2f")% ")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .frame(height: 20, alignment: .center) // テキストの高さをプログレスバーと同じにして中央揃え
            }
            
        }
        .padding()
    }
}
