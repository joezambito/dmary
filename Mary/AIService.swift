//
//  AIService.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

//
//import Foundation

/// StackExchangeAIService
/// - Defensive: refuses empty or greeting-only queries.
/// - Does not rely on any non-public Settings initializer.
import Foundation

// Simple AIService protocol used by the implementation.
public protocol AIService {
    func send(prompt: String, completion: @escaping (Result<String, Error>) -> Void)
}

/// Configuration container for Stack Exchange requests.
public struct StackExchangeSettings {
    public var apiBaseURL: String?
    public var stackExchangeKey: String?

    public init(apiBaseURL: String? = nil, stackExchangeKey: String? = nil) {
        self.apiBaseURL = apiBaseURL
        self.stackExchangeKey = stackExchangeKey
    }
}

public final class StackExchangeAIServiceImpl: AIService {
    private let session: URLSession
    private let baseURL: URL
    private let settings: StackExchangeSettings

    public init(baseURL: URL = URL(string: "https://example.com")!,
                settings: StackExchangeSettings = StackExchangeSettings(),
                session: URLSession = .shared) {
        self.baseURL = baseURL
        self.settings = settings
        self.session = session
    }

    // MARK: - Simple AIService send

    public func send(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            completion(.failure(NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid base URL"])))
            return
        }
        components.path = "/api/ask"
        components.queryItems = [URLQueryItem(name: "q", value: prompt)]

        guard let url = components.url else {
            completion(.failure(NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request URL"])))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        session.dataTask(with: req) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                completion(.failure(NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "HTTP error"])))
                return
            }
            guard let data = data, let text = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            completion(.success(text))
        }.resume()
    }

    // MARK: - Networking Core

    public func performRequest(_ request: URLRequest,
                               completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request, completionHandler: completion).resume()
    }

    public func handleResponse(data: Data?,
                               response: URLResponse?,
                               error: Error?,
                               completion: @escaping (Result<(Data, Int), Error>) -> Void) {

        if let error = error {
            completion(.failure(error))
            return
        }

        guard let http = response as? HTTPURLResponse,
              let data = data else {
            let err = NSError(domain: "StackExchangeAIService",
                              code: -4,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            completion(.failure(err))
            return
        }

        completion(.success((data, http.statusCode)))
    }

    // MARK: - Public API

    /// Call the Stack Exchange search API.
    /// This method defensively rejects empty or greeting-only queries.
    public func callStackExchange(queryData: Data,
                                  completion: @escaping (Result<(Data, Int), Error>) -> Void) {

        guard let raw = String(data: queryData, encoding: .utf8) else {
            let err = NSError(domain: "StackExchangeAIService",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Unable to decode query data"])
            completion(.failure(err))
            return
        }

        let query = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            let err = NSError(domain: "StackExchangeAIService",
                              code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "Empty query"])
            completion(.failure(err))
            return
        }

        if isGreeting(query) {
            let err = NSError(domain: "StackExchangeAIService",
                              code: -5,
                              userInfo: [NSLocalizedDescriptionKey: "Query appears to be a greeting; no search performed"])
            completion(.failure(err))
            return
        }

        // Build URLComponents for Stack Exchange. Use apiBaseURL if provided, otherwise default.
        let base = settings.apiBaseURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        var comps = URLComponents()
        if let base = base, let baseURL = URL(string: base), let host = baseURL.host {
            comps.scheme = baseURL.scheme ?? "https"
            comps.host = host
            let trimmedPath = baseURL.path.hasSuffix("/") ? String(baseURL.path.dropLast()) : baseURL.path
            comps.path = trimmedPath + "/2.3/search/advanced"
        } else {
            comps.scheme = "https"
            comps.host = "api.stackexchange.com"
            comps.path = "/2.3/search/advanced"
        }

        comps.queryItems = [
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "site", value: "stackoverflow"),
            URLQueryItem(name: "pagesize", value: "10"),
            URLQueryItem(name: "title", value: query)
        ]

        if let key = settings.stackExchangeKey, !key.isEmpty {
            comps.queryItems?.append(URLQueryItem(name: "key", value: key))
        }

        guard let url = comps.url else {
            let err = NSError(domain: "StackExchangeAIService",
                              code: -3,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid Stack Exchange URL"])
            completion(.failure(err))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = 20

        // Debug log (safe): print the final URL so you can verify no accidental queries happen.
        print("[StackExchangeAIService] Request URL:", url.absoluteString)

        performRequest(req) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
    }

    // MARK: - Helpers

    private func isGreeting(_ text: String) -> Bool {
        let lower = text.lowercased()
        let greetings = ["hi", "hello", "hey", "hi mary", "hello mary", "hey mary"]
        return greetings.contains { lower == $0 || lower.hasPrefix("\($0) ") }
    }
}
