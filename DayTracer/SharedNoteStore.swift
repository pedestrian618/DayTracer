//
//  SharedNoteStore.swift
//  DayTracer
//
//  アプリ（書き込み）とウィジェット（読み込み）が共有する、最新ノートの保存先。
//  App Group の UserDefaults をラップする。
//

import Foundation

struct SharedNoteStore {
    private let defaults: UserDefaults?

    init(suiteName: String = SharedConfig.appGroupID) {
        self.defaults = UserDefaults(suiteName: suiteName)
    }

    /// 最新ノートを共有コンテナへ保存する（アプリ側で使用）。
    func saveLatestNote(text: String, date: String) {
        defaults?.set(text, forKey: SharedConfig.Keys.latestNoteText)
        defaults?.set(date, forKey: SharedConfig.Keys.latestNoteDate)
    }

    /// 最新ノートを読み出す（ウィジェット側で使用）。未保存ならプレースホルダを返す。
    func loadLatestNote() -> (text: String, date: String) {
        let text = defaults?.string(forKey: SharedConfig.Keys.latestNoteText) ?? "No Note.Let’s take your diary"
        let date = defaults?.string(forKey: SharedConfig.Keys.latestNoteDate) ?? ""
        return (text, date)
    }
}
