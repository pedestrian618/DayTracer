//
//  NotesView.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//


import SwiftUI
import Firebase
import FirebaseAuth

// MARK: - Date Extension
extension Date {
    /// 表示設定（日付・時刻形式）に従ったタイムスタンプ文字列。
    func formatted() -> String {
        return AppSettings.dateTimeString(from: self)
    }

    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}

// MARK: - Diary Entry Model
struct DiaryEntry: Identifiable {
    var id: String
    var text: String
    var date: Date

    init?(id: String, data: [String: Any]) {
        guard let text = data["text"] as? String,
              let timestamp = data["date"] as? Timestamp else { return nil }
        self.id = id
        self.text = text
        self.date = timestamp.dateValue()
    }
}

// MARK: - Diary Entry View
struct DiaryEntryView: View {
    var entry: DiaryEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.text)
                    .font(.body)
                Text(entry.date.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Notes View
struct NotesView: View {
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var newDiaryText: String = ""
    @State private var errorMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool

    /// 「短い日記」を保つための1投稿あたりの最大文字数。
    private let maxNoteLength = 30

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(diaryEntries) { entry in
                        DiaryEntryView(entry: entry)
                    }
                    .onDelete(perform: deleteEntry)
                }

                inputArea

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logoImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
            }
            .onAppear(perform: loadDiaryEntries)
        }
    }

    // MARK: - 入力エリア（短い日記の制約つき）
    private var inputArea: some View {
        VStack(spacing: 4) {
            HStack {
                TextField("Type your Note...", text: $newDiaryText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .focused($isTextFieldFocused)
                    .disabled(hasPostedToday())
                    .onChange(of: newDiaryText) { _, newValue in
                        // 文字数上限を超えたら切り詰める（短い日記の制約）
                        if newValue.count > maxNoteLength {
                            newDiaryText = String(newValue.prefix(maxNoteLength))
                        }
                    }

                Button(action: addNewDiaryEntry) {
                    Text("Post")
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(8)
                }
                .disabled(newDiaryText.isEmpty || hasPostedToday())
            }

            HStack {
                if hasPostedToday() {
                    Text("今日はもう投稿しました")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(newDiaryText.count)/\(maxNoteLength)")
                    .font(.caption)
                    .foregroundColor(newDiaryText.count >= maxNoteLength ? .orange : .gray)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // MARK: - CRUD Operations
    private func addNewDiaryEntry() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let newEntryRef = db.collection("diaryEntries").document()
        let entryData: [String: Any] = [
            "text": newDiaryText,
            "date": Timestamp(date: Date()),
            "userId": userId
        ]

        newEntryRef.setData(entryData) { error in
            if let error = error {
                errorMessage = "Error saving entry: \(error.localizedDescription)"
            } else {
                let newEntry = DiaryEntry(id: newEntryRef.documentID, data: entryData)
                if let newEntry = newEntry {
                    diaryEntries.insert(newEntry, at: 0)
                    saveLatestDiaryEntryInSharedContainer(entry: newEntry)
                    newDiaryText = ""
                    isTextFieldFocused = false
                }
            }
        }
    }

    private func loadDiaryEntries() {
        DiaryRepository().fetchLatest { result in
            switch result {
            case .success(let entries):
                diaryEntries = entries
            case .failure(let error):
                errorMessage = "Error loading entries: \(error.localizedDescription)"
            }
        }
    }

    private func deleteEntry(at offsets: IndexSet) {
        offsets.forEach { index in
            let entry = diaryEntries[index]
            deleteDiaryEntry(entryId: entry.id)
            diaryEntries.remove(at: index)
        }
    }

    private func deleteDiaryEntry(entryId: String) {
        Firestore.firestore().collection("diaryEntries").document(entryId).delete { error in
            if let error = error {
                errorMessage = "Error deleting entry: \(error.localizedDescription)"
            }
        }
    }

    /// 1日1投稿の制約: 最新エントリの日付が今日なら true。
    private func hasPostedToday() -> Bool {
        guard let latest = diaryEntries.first else { return false }
        return latest.date.isSameDay(as: Date())
    }

    private func saveLatestDiaryEntryInSharedContainer(entry: DiaryEntry) {
        SharedNoteStore().saveLatestNote(text: entry.text, date: entry.date.formatted())
    }
}
