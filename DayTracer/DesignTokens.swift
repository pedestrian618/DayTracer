//
//  DesignTokens.swift
//  DayTracer
//
//  デザイントークン。色・フォント・寸法をここに集約し、View にリテラル値を書かない。
//  アプリ・ウィジェット両ターゲットでソース共有し、「ダークな計器盤」の世界観を統一する。
//
//  設計方針:
//  - ほぼ黒の盤面 + 白の数字 + 差し色1色（アンバー）。
//  - アンバーは「残り時間」を表す箇所にだけ使い、装飾には使わない。
//  - 数字は全て等幅（monospaced）。桁が動き続けてもレイアウトがガタつかない。
//

import SwiftUI

enum DS {
    // MARK: - Colors

    enum Colors {
        /// 盤面（画面背景）
        static let panel = Color(red: 0x0A / 255, green: 0x0C / 255, blue: 0x10 / 255)
        /// カード・セクションの面
        static let surface = Color(red: 0x13 / 255, green: 0x16 / 255, blue: 0x1C / 255)
        /// 罫線・グリッド線・未来セルの輪郭
        static let line = Color(red: 0x2A / 255, green: 0x30 / 255, blue: 0x3A / 255)
        /// 主文字（数字・本文）
        static let numeral = Color(red: 0xF2 / 255, green: 0xF3 / 255, blue: 0xF5 / 255)
        /// 補助文字（ラベル・単位・キャプション）
        static let label = Color(red: 0x8A / 255, green: 0x91 / 255, blue: 0x9C / 255)
        /// 差し色: 残り時間（アンバー）
        static let remaining = Color(red: 0xFF / 255, green: 0xB0 / 255, blue: 0x20 / 255)
        /// 消費済みの時間（燃え尽きた領域）
        static let spent = Color(red: 0x2E / 255, green: 0x33 / 255, blue: 0x3D / 255)
        /// 消費済み領域に重ねる斜線ハッチの線色
        static let hatch = Color.black.opacity(0.35)
    }

    // MARK: - Fonts

    enum Fonts {
        /// 数字用の等幅フォント
        static func numeral(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
            .system(size: size, weight: weight, design: .monospaced)
        }

        /// ヒーロー数字（年の残り%）
        static let hero = numeral(42)
        /// ヒーロー直下のカウントダウン（残り日数・時刻）
        static let countdown = numeral(17, weight: .semibold)
        /// バー横の残量数値
        static let barValue = numeral(15, weight: .semibold)
        /// セクションラベル（YEAR / DAY など）
        static let sectionLabel = numeral(11, weight: .semibold)
        /// ホームの時計
        static let clock = numeral(34)
        /// 時計の秒
        static let clockSeconds = numeral(20)
        /// 日付表示
        static let date = numeral(14, weight: .semibold)
        /// 本文（記録テキストなど）
        static let body = Font.system(size: 15)
        /// キャプション
        static let caption = Font.system(size: 12)
    }

    // MARK: - Metrics

    enum Metrics {
        static let screenPadding: CGFloat = 20
        static let spacing: CGFloat = 12
        static let spacingLarge: CGFloat = 26
        static let cardCorner: CGFloat = 10
        static let barHeight: CGFloat = 10
        static let barHeightThin: CGFloat = 6
        /// 年間グリッドの列数とセル間隔
        static let yearGridColumns = 26
        static let yearGridGap: CGFloat = 3
    }
}
