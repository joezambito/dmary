//
//  MarySearchService.swift
//  Mary
//
//  Created by Joe Zambito on 30/4/2026.
//

import Foundation

/// A simple data model for a single search result.
struct MarySearchResult: Codable {
    let title: String
    let snippet: String
}

/// CLEANED: A high-speed network bridge.
/// No formatting logic. It returns raw data for the Brain to handle.
class MarySearchService {
    
    private let searchEndpoint = "https://api.your-search-provider.com/search"
    private let apiKey = "YOUR_API_KEY_HERE"
    
    func performSearch(_ query: String) async -> [MarySearchResult] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(searchEndpoint)?q=\(encodedQuery)&api_key=\(apiKey)") else {
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            
            // Parse raw JSON into our data model
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let results = json["organic_results"] as? [[String: Any]] {
                
                return results.compactMap { dict in
                    guard let title = dict["title"] as? String,
                          let snippet = dict["snippet"] as? String else { return nil }
                    return MarySearchResult(title: title, snippet: snippet)
                }
            }
            return []
            
        } catch {
            print("Search Error: \(error.localizedDescription)")
            return []
        }
    }
}
