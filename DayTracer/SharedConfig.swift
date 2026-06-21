//
//  SharedConfig.swift
//  DayTracer
//
//  アプリとウィジェットで共有する App Group の設定。
//  suite 名やキー名をここに集約し、文字列の二重管理（タイプミスで連携が壊れる事故）を防ぐ。
//

import Foundation

enum SharedConfig {
    /// App Group の suite identifier。
    static let appGroupID = "group.junkyfly.daytracer.notes"

    /// App Group の共有 UserDefaults（ノート・表示設定の共有に使用）。
    static let defaults = UserDefaults(suiteName: appGroupID)

    /// 共有 UserDefaults のキー。
    enum Keys {
        static let latestNoteText = "latestNoteText"
        static let latestNoteDate = "latestNoteDate"
    }
}
