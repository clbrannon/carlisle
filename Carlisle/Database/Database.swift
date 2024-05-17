//
//  Database.swift
//  Carlisle
//
//  Created by Christopher on 5/15/24.
//
//  Most of these are not needed at the moment

import Foundation

// Function to save a single threadId to a file
func saveThreadId(_ threadId: String) {
    
    print("Saving Thread ID")

    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return
    }
    
    let fileURL = documentsDirectory.appendingPathComponent("threadId.txt")
    
    do {
        try threadId.write(to: fileURL, atomically: true, encoding: .utf8)
        print("Thread ID saved successfully")
    } catch {
        print("Error saving Thread ID on: \(error)")
    }
}

func retrieveThreadId() -> String? {
    // Get the URL of the Documents directory
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return nil
    }
    
    let fileURL = documentsDirectory.appendingPathComponent("threadId.txt")
    

    do {
        let threadId = try String(contentsOf: fileURL)
        return threadId
    } catch {
        print("Error reading threadId: \(error)")
        return nil
    }
}

// Function to save an array of Chat objects to a file
func saveChats(_ chat: Chat) {

    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return
    }
    
    let fileURL = documentsDirectory.appendingPathComponent("chats.json")
    
    var existingChats: [Chat] = []
    if let existingData = try? Data(contentsOf: fileURL) {
        let decoder = JSONDecoder()
        do {
            existingChats = try decoder.decode([Chat].self, from: existingData)
        } catch {
            print("Error decoding existing chats: \(error)")
        }
    }
    
    existingChats.append(chat)
    let updatedChats = existingChats

    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(updatedChats)
        
        try jsonData.write(to: fileURL, options: .atomic)
        print("Chat saved successfully")
    } catch {
        print("Error saving chats: \(error)")
    }
}

func retrieveChats() -> [Chat]? {

    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return nil
    }
    
    let fileURL = documentsDirectory.appendingPathComponent("chats.json")
    
    do {
        let jsonData = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let chats = try decoder.decode([Chat].self, from: jsonData)
        return chats
    } catch {
        print("Error retrieving chats: \(error)")
        return nil
    }
}
