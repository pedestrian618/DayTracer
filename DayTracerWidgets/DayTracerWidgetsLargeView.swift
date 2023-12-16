//
//  DayTracerWidgetsLargeView.swift
//  DayTracerWidgetsExtension
//
//  Created by murate on 2023/12/10.
//

import SwiftUI

struct DayTracerWidgetsLargeView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            // Smallサイズのウィジェットに適したコンテンツ
            Text("Time:")
                .font(.headline)
            Text(entry.date, style: .time)
                .font(.subheadline)
            
            Spacer()
            
            // 年間の進捗を表示
            Text("Year Progress:")
            //            ProgressView(value: entry.yearProgress)
            //                .progressViewStyle(LinearProgressViewStyle())
            //                .scaleEffect(x: 1, y: 1, anchor: .center) // サイズを調整
            CustomLinearProgressView(progress: entry.yearProgress, color: .blue)
                .frame(height: 20)
                .padding(.bottom, 5)
        }
        .padding()
    }
}
