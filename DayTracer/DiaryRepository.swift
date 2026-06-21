//
//  DiaryRepository.swift
//  DayTracer
//
//  Firestore の diaryEntries コレクションへのアクセスを集約する。
//  NotesView（一覧）と HomeView（最新数件）が共通で使う。
//

import Foundation
import Firebase
import FirebaseAuth

struct DiaryRepository {
    private let collectionName = "diaryEntries"

    /// 現在のユーザーの日記を新しい順に取得する。`limit` 指定で最新 N 件のみ。
    /// 未サインインのときは空配列を返す。完了ハンドラは Firestore 既定でメインスレッドで呼ばれる。
    func fetchLatest(limit: Int? = nil, completion: @escaping (Result<[DiaryEntry], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }

        var query = Firestore.firestore().collection(collectionName)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
        if let limit = limit {
            query = query.limit(to: limit)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                let entries = snapshot?.documents.compactMap {
                    DiaryEntry(id: $0.documentID, data: $0.data())
                } ?? []
                completion(.success(entries))
            }
        }
    }
}
