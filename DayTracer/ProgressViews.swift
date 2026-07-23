//
//  ProgressViews.swift
//  DayTracer
//
//  進捗表示の共有コンポーネント。アプリ・ウィジェット両ターゲットで使う。
//  「経過を積み上げる」のではなく「残量が削られていく」見せ方を担う。
//

import SwiftUI

/// 45°の斜線ハッチ。消費済み（もう戻らない）領域の質感に使う。
struct StripedPattern: View {
    var color: Color = DS.Colors.hatch
    var lineWidth: CGFloat = 1
    var gap: CGFloat = 4

    var body: some View {
        Canvas { context, size in
            let step = lineWidth + gap
            var x: CGFloat = -size.height
            while x < size.width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                context.stroke(path, with: .color(color), lineWidth: lineWidth)
                x += step
            }
        }
    }
}

/// 「残量」が主役のバー。左（消費済み）は暗いハッチ、右（残り）だけがアンバーに光る。
/// `progress` は経過率 0.0〜1.0。残量側の幅 = (1 - progress)。
struct DrainBarView: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            let clamped = CGFloat(min(max(progress, 0), 1))
            let spentWidth = clamped * geometry.size.width
            HStack(spacing: 0) {
                DS.Colors.spent
                    .overlay(StripedPattern())
                    .frame(width: spentWidth)
                DS.Colors.remaining
                    .frame(width: geometry.size.width - spentWidth)
            }
            .clipShape(Capsule())
        }
    }
}
