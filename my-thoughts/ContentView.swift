//
//  ContentView.swift
//  my-thoughts
//
//  Created by Olivia on 7/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var journalText: String = ""
    @State private var saveMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What are you thinking about right now?")
                .font(.custom("NunitoSans-Bold", size: 16))
            ZStack(alignment: .topLeading) {
                if journalText.isEmpty {
                    Text("Write your thoughts here...")
                        .foregroundColor(Color.mainText)
                        .padding(.all, 14)
                        .font(.custom("NunitoSans-Regular", size: 13))
                }
                TextEditor(text: $journalText)
                    .font(.custom("NunitoSans-Regular", size: 12))
                    .padding(.all, 8)
                    .background(Color.surface)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                    )
                    .scrollContentBackground(.hidden)
            }
            .frame(height: 180)
            HStack {
                if let message = saveMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.success)
                        Text(message)
                            .font(.custom("NunitoSans-Bold", size: 14))
                            .foregroundColor(Color.success)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.successLight)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                } else if let error = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.errorRed)
                        Text(error)
                            .font(.custom("NunitoSans-Bold", size: 14))
                            .foregroundColor(Color.errorRed)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.lightRed)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                } else {
                    Button(action: saveEntry) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Save Thoughts")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .font(.custom("NunitoSans-Bold", size: 14))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 300)
        .background(Color.surfaceContainer)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveEntry() {
        print("[DEBUG] saveEntry called")
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let journalDir = documentsURL.appendingPathComponent("MyThoughts")
        print("[DEBUG] Journal directory: \(journalDir.path)")
        if !fileManager.fileExists(atPath: journalDir.path) {
            do {
                try fileManager.createDirectory(at: journalDir, withIntermediateDirectories: true)
                print("[DEBUG] Created directory: \(journalDir.path)")
            } catch {
                print("[ERROR] Failed to create directory: \(error)")
                alertMessage = "Failed to create journal folder."
                showAlert = true
                return
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM d yyyy"
        let rawName = dateFormatter.string(from: Date())
        let fileName = rawName.replacingOccurrences(of: " ", with: "") + ".txt"
        let fileURL = journalDir.appendingPathComponent(fileName)
        print("[DEBUG] File path: \(fileURL.path)")
        let entry = "\n\n---\n\(Date())\n\(journalText)"
        if let data = entry.data(using: .utf8) {
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                    print("[DEBUG] Appended entry to file.")
                } catch {
                    print("[ERROR] Failed to append to file: \(error)")
                    alertMessage = "Failed to save entry."
                    showAlert = true
                    return
                }
            } else {
                do {
                    try data.write(to: fileURL)
                    print("[DEBUG] Created new file and wrote entry.")
                } catch {
                    print("[ERROR] Failed to write new file: \(error)")
                    alertMessage = "Failed to save entry."
                    showAlert = true
                    return
                }
            }
            saveMessage = "Entry saved!"
            journalText = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                saveMessage = nil
            }
        } else {
            print("[ERROR] Failed to encode entry as UTF-8.")
            alertMessage = "Failed to save entry."
            showAlert = true
        }
    }
}

#Preview {
    ContentView()
}
