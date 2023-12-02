//
//  NotesView.swift
//  DayTracer
//
//  Created by murate on 2023/12/02.
//


import SwiftUI

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
                                        .padding()
                        
                        Button(action: addNewDiaryEntry) {
                            Text("Post")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(newDiaryText.isEmpty)
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
                }
            }
        }

    private func deleteEntry(at offsets: IndexSet) {
        diaryEntries.remove(atOffsets: offsets)
    }

    private func addNewDiaryEntry() {
        let newEntry = DiaryEntry(text: newDiaryText, date: Date())
        diaryEntries.insert(newEntry, at: 0) // Add new entry at the beginning of the list
        newDiaryText = "" // Reset the text field
        // Hide the keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
