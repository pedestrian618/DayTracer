//
//  NotesView.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//


import SwiftUI
import FirebaseCore
import FirebaseAuth
import Firebase
import GoogleSignIn


extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// Diary entry data model
struct DiaryEntry: Identifiable {
    var id = UUID()
    var text: String
    var date: Date
}

// View for individual diary entry
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
// Notes view with a list of diary entries
struct NotesView: View {
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var newDiaryText: String = "" // State variable for user input
    @State private var errorMessage = "" // エラーメッセージ用の状態変数

    var body: some View {
            NavigationView { // Adding NavigationView here
                VStack {
                    // Existing ScrollView for diary entries
                    List {
                            ForEach(diaryEntries) { entry in
                                DiaryEntryView(entry: entry)
                            }
                            .onDelete(perform: deleteEntry) // Add swipe to delete action
                        }
                    
                    // TextField and Button for new diary entry
                    HStack {
                        TextField("Type your diary...", text: $newDiaryText)
                            .onReceive(newDiaryText.publisher.collect()) {
                                newDiaryText = String($0.prefix(100)) // Limit to 100 characters
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .background(Color.clear)
                            .padding()
                        
                        Button(action: addNewDiaryEntry) {
                            Text("Post")
                                .foregroundColor(.white)
                                .padding()
                                .frame(height: 40) // 例: 入力欄と同じ高さに合わせる
                                .background(Color.blue.opacity(0.7))
                                .cornerRadius(8)
                        }
                        .disabled(newDiaryText.isEmpty)
                        // デバッグメッセージを表示
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Notes") // Set the title for the navigation bar
                .navigationBarTitleDisplayMode(.inline).toolbar {
                    ToolbarItem(placement: .principal) {
                        Image("logoImage") // ロゴ画像
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40) // 適切なサイズに調整
                    }
                }.onAppear {
                    loadDiaryEntries()
                }
            }
        }

    private func deleteEntry(at offsets: IndexSet) {
        diaryEntries.remove(atOffsets: offsets)
    }

    private func addNewDiaryEntry() {
        let newEntry = DiaryEntry(text: newDiaryText, date: Date())
        diaryEntries.insert(newEntry, at: 0) // Add new entry at the beginning of the list
        saveDiaryEntry(entry: newEntry) // Cloud Firestoreに保存
        newDiaryText = "" // Reset the text field
        // Hide the keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveDiaryEntry(entry: DiaryEntry) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let entryData: [String: Any] = [
            "text": entry.text,
            "date": entry.date,
            "userId": userId
        ]

        db.collection("diaryEntries").addDocument(data: entryData) { error in
            if let error = error {
                print("Error saving diary entry: \(error.localizedDescription)")
            } else {
                print("Diary entry successfully saved")
                self.saveLatestDiaryEntryInSharedContainer(entry: entry)
            }
        }
    }
    
    func saveLatestDiaryEntryInSharedContainer(entry: DiaryEntry) {
        let sharedDefaults = UserDefaults(suiteName: "group.junkyfly.daytracer.notes")
        sharedDefaults?.set(entry.text, forKey: "latestNoteText")
        sharedDefaults?.set(entry.date.formatted(), forKey: "latestNoteDate")
    }
    
    func loadDiaryEntries() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("diaryEntries")
          .whereField("userId", isEqualTo: userId)
          .order(by: "date", descending: true) // 最新のエントリが先に来るように
          .getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.diaryEntries = querySnapshot?.documents.compactMap { document -> DiaryEntry? in
                    let data = document.data()
                    let text = data["text"] as? String ?? ""
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    return DiaryEntry(text: text, date: date)
                } ?? []
            }
        }
    }
    
    func deleteDiaryEntry(entryId: String) {
        let db = Firestore.firestore()

        db.collection("diaryEntries").document(entryId).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    

}


