//
//  MaryProjectMemory.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation
import Combine

/// CLEANED: This is now a Pure Database (Archive).
/// It stores raw data and does not invent 'Context Strings' or speak for Mary.
class MaryProjectMemory: ObservableObject {
    
    struct MemoryEntry: Identifiable, Codable {
        let id: UUID
        let timestamp: Date
        let type: MemoryType
        let content: String
        let project: String
    }
    
    enum MemoryType: String, Codable {
        case codeSnippet, terminalError, searchResult, apiConfig, taskRequirement
    }
    
    @Published var entries: [MemoryEntry] = []
    private let storageKey = "MaryInternalMemory"
    
    init() {
        loadFromDisk()
    }
    
    /// CLEANED: Stores data silently. Persistence is now handled more safely.
    func store(type: MemoryType, content: String, project: String = "Global") {
        let newEntry = MemoryEntry(id: UUID(), timestamp: Date(), type: type, content: content, project: project)
        entries.append(newEntry)
        
        // Keep memory lean
        if entries.count > 500 {
            entries.removeFirst()
        }
        
        // Save in background to prevent UI lag
        DispatchQueue.global(qos: .background).async {
            self.saveToDisk()
        }
    }
    
    /// CLEANED: Returns raw data objects. 
    /// The Main Brain will decide which ones are 'Relevant' and how to format them.
    func fetchRawEntries(for project: String) -> [MemoryEntry] {
        return entries.filter { $0.project == project || $0.project == "Global" }
    }
    
    func clearAllMemory() {
        entries.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
        // No more 'Mary Speaking' prints here.
    }
    
    // MARK: - Persistence Logic
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([MemoryEntry].self, from: data) {
            self.entries = decoded
        }
    }
}
