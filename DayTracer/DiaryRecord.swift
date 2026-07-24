//
//  DiaryRecord.swift
//  DayTracer
//
//  使途記録のローカルモデル（SwiftData）。Firestore 依存を撤去し、オフラインファーストに。
//  CloudKit 同期を後から有効化できるよう、全プロパティにデフォルト値を持たせている
//  （CloudKit 対応スキーマの要件。ユニーク制約も使わない）。
//

import Foundation
import SwiftData

@Model
final class DiaryRecord {
    var text: String = ""
    var date: Date = Date()

    init(text: String, date: Date = Date()) {
        self.text = text
        self.date = date
    }
}
