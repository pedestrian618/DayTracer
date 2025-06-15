//
//  DiaryView.swift
//  DayTracer
//
//  Created by murate on 2025/02/16.
//

import SwiftUI
import Firebase
import FirebaseAuth

// MARK: - Date Extension
extension Date {
    static let shortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    func formatted() -> String {
        return Date.shortFormatter.string(from: self)
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
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

// MARK: - Diary View
struct DiaryView: View {
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var newDiaryText: String = ""
    @State private var errorMessage: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(diaryEntries) { entry in
                        DiaryEntryView(entry: entry)
                    }
                }
                .onTapGesture {
                    isTextFieldFocused = false
                }
                
                HStack {
                    TextField("Type your diary...", text: $newDiaryText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                        .focused($isTextFieldFocused)
                        .onChange(of: newDiaryText) { newValue in
                            if newValue.count > 30 {
                                newDiaryText = String(newValue.prefix(30))
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
                .padding()
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("")
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
                    newDiaryText = ""
                    isTextFieldFocused = false
                }
            }
        }
    }
    
    private func loadDiaryEntries() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("diaryEntries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Error loading entries: \(error.localizedDescription)"
                } else {
                    diaryEntries = snapshot?.documents.compactMap {
                        DiaryEntry(id: $0.documentID, data: $0.data())
                    } ?? []
                }
            }
    }
    
    private func hasPostedToday() -> Bool {
        guard let latestEntry = diaryEntries.first else { return false }
        return latestEntry.date.isSameDay(as: Date())
    }
}

