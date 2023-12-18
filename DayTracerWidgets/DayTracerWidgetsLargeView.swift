//
//  DayTracerWidgetsLargeView.swift
//  DayTracerWidgetsExtension
//
//  Created by murate on 2023/12/10.
//

import SwiftUI

struct DayTracerWidgetsLargeView: View {
    var entry: Provider.Entry
    let currentYear = String(Calendar.current.component(.year, from: Date()))
    let currentMonth = String(Calendar.current.component(.month, from: Date()))
    let currentMonthName = DateFormatter().monthSymbols[Calendar.current.component(.month, from: Date()) - 1]
    @Environment(\.colorScheme) var colorScheme
    
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    
                    // 左上に時間と曜日、日付とノートを縦方向に積み上げ
                    VStack(alignment: .leading) {
                        
                        Text(entry.date, style: .time)
                            .font(.system(size: 36, weight: .bold, design: .default))
                            .padding(.leading, 20)
                        Text(entry.date.formattedAsDayMonthDate())
                            .font(.system(size: 24, weight: .regular, design: .default))
                            .padding(.leading, 20)
//                        Text(entry.date, style: .date)
//                            .font(.system(size: 18, weight: .regular, design: .default))
//                            .padding(.leading, 20)
                    }
                    
                    //Spacer()
                    // 今日の24時間の進捗を表示する円形プログレスバー
                    ZStack {
                        CustomCircleProgressGradientView(progress: entry.dayProgress, gradient: Gradient(colors: [entry.selectedSubColor.opacity(0.55), entry.selectedColor]),size: 85)
                        Text("\(Int(entry.dayProgress * 100))%")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .frame(height: 20, alignment: .center)
                    }
                }
                //.padding()
                
                
                
                
                // 年間の進捗を表示する線形プログレスバー
                ZStack(alignment: .center) { // ZStackに中央揃えを指定
                    CustomLinearProgressGradientView(progress: entry.yearProgress, gradient: Gradient(colors: [entry.selectedSubColor.opacity(0.55), entry.selectedColor]))
                        .frame(height: 20) // プログレスバーの高さを指定
                    
                    Text("\(currentYear) : \(entry.yearProgress * 100, specifier: "%.2f")% Complete")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(height: 20, alignment: .center) // テキストの高さをプログレスバーと同じにして中央揃え
                }
                .padding(.horizontal) // ZStackに対するパディング
                
                // 年間の進捗を表示する線形プログレスバー
                ZStack(alignment: .center) { // ZStackに中央揃えを指定
                    CustomLinearProgressGradientView(progress: entry.monthProgress, gradient: Gradient(colors: [entry.selectedSubColor.opacity(0.55), entry.selectedColor])).frame(height: 20)
                    
                    Text("\(currentMonthName) : \(entry.monthProgress * 100, specifier: "%.2f")% Complete")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .frame(height: 20, alignment: .center)
                }
                .padding(.horizontal) 
                
                // ノートを取るためのボタン
                Button(action: {
                    // ノートビューへのアクションを追加
                }) {
                    HStack {
                        Image(systemName: "pencil")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Text("Take Notes")
                            .font(.system(size: 18, weight: .regular, design: .default))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                        Spacer() // 左側に寄せるためのスペーサー
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading) // これによりボタンは親ビューの幅に合わせて広がります
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor.systemGray3))
                .padding(.horizontal) // 角を丸く
            }
        }
}

