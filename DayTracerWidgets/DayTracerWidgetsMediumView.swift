//
//  DayTracerWidgetsMidiumView.swift
//  DayTracerWidgetsExtension
//
//  Created by murate on 2023/12/10.
//

import SwiftUI

struct DayTracerWidgetsMediumView: View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    // 左上に時間と曜日、日付とノートを縦方向に積み上げ
                    VStack(alignment: .leading) {
                        
                        Text(entry.date, style: .time)
                            .font(.system(size: 32, weight: .bold, design: .default))
                        Text(entry.date, style: .date)
                            .font(.system(size: 18, weight: .regular, design: .default))
                        
                        // ノートを取るためのボタン
                        Button(action: {
                            // ノートビューへのアクションを追加
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                Text("Take Notes         ")
                                    .font(.system(size: 18, weight: .regular,design: .default))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(UIColor.systemGray3))
                        .padding(.horizontal)// 角を丸く
                    }
                    
                    //Spacer()
                    // 今日の24時間の進捗を表示する円形プログレスバー
                    CustomCircleProgressView(progress: entry.dayProgress, color: .blue,size: 75)
                }
                //.padding()
                
                
                
                
                // 年間の進捗を表示する線形プログレスバー
                ZStack(alignment: .center) { // ZStackに中央揃えを指定
                    CustomLinearProgressView(progress: entry.yearProgress, color: .blue)
                        .frame(height: 20) // プログレスバーの高さを指定
                    
                    Text("This year \(entry.yearProgress * 100, specifier: "%.2f")% processed")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(height: 20, alignment: .center) // テキストの高さをプログレスバーと同じにして中央揃え
                }
                .padding(.horizontal) // ZStackに対するパディング
            }
        }
}

