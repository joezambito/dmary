//
//  MaryLocalLLMService.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

//
//  MaryLocalLLMService.swift
//  Mary
//

import Foundation

// MARK: - Backend Manager
actor MaryBackendManager {
    static let shared = MaryBackendManager()

    private var process: Process?
    private let healthURL = URL(string: "http://127.0.0.1:8082/health")!
    private let startupTimeoutSeconds: Int = 20

    func ensureRunning() async -> Bool {
        if await isServerReachable() { return true }

        if process?.isRunning != true {
            startBackend()
        }

        for _ in 0..<startupTimeoutSeconds {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if await isServerReachable() { return true }
        }

        return false
    }

    private func isServerReachable() async -> Bool {
        var request = URLRequest(url: healthURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 1.5

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return false }
            return (200...299).contains(http.statusCode)
        } catch {
            return false
        }
    }

    private func startBackend() {
        // Keep your current local script path
        let scriptPath = "/Users/joezambito/Mary/start_mary_backend.sh"
        guard FileManager.default.fileExists(atPath: scriptPath) else { return }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["--login", scriptPath]
        task.standardInput = Pipe()
        task.standardOutput = Pipe()
        task.standardError = Pipe()

        do {
            try task.run()
            process = task
        } catch {
            // Intentionally silent here; caller handles availability check result
        }
    }
}

// MARK: - LLM Service
struct MaryLocalLLMService {
    private let completionURL = URL(string: "http://127.0.0.1:8082/v1/chat/completions")!

    struct LLMMessage: Codable {
        let role: String
        let content: String
    }

    struct ChatCompletionRequest: Codable {
        let messages: [LLMMessage]
        let max_tokens: Int
        let temperature: Double
        let stop: [String]
    }

    struct ChatCompletionResponse: Codable {
        struct Choice: Codable {
            struct Message: Codable {
                let role: String?
                let content: String?
            }
            let message: Message?
        }
        let choices: [Choice]?
    }

    /// Basic single-prompt call
    func generateResponse(
        prompt: String,
        maxTokens: Int = 1000,
        temp: Double = 0.05
    ) async -> String {
        let messages = [LLMMessage(role: "user", content: prompt)]
        return await generateResponse(
            messages: messages,
            maxTokens: maxTokens,
            temp: temp
        )
    }

    /// Thread-aware call (pass full message history if you want)
    func generateResponse(
        messages: [LLMMessage],
        maxTokens: Int = 1000,
        temp: Double = 0.05
    ) async -> String {
        let ready = await MaryBackendManager.shared.ensureRunning()
        guard ready else {
            return "BACKEND_ERROR: Server not reachable at 127.0.0.1:8082"
        }

        let body = ChatCompletionRequest(
            messages: messages,
            max_tokens: maxTokens,
            temperature: temp,
            stop: ["<|im_end|>", "```", "Joe:", "Mary:"]
        )

        var request = URLRequest(url: completionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 200

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return "BACKEND_ERROR: Failed to encode request (\(error.localizedDescription))"
        }

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 200
        config.timeoutIntervalForResource = 240
        let session = URLSession(configuration: config)

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return "BACKEND_ERROR: Invalid HTTP response"
            }

            guard (200...299).contains(http.statusCode) else {
                let bodyText = String(data: data, encoding: .utf8) ?? "No response body"
                return "BACKEND_ERROR: HTTP \(http.statusCode) - \(bodyText)"
            }

            let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            if let content = decoded.choices?.first?.message?.content?.trimmingCharacters(in: .whitespacesAndNewlines),
               !content.isEmpty {
                return content
            }

            return "BACKEND_ERROR: Empty model response"
        } catch {
            return "BACKEND_ERROR: \(error.localizedDescription)"
        }
    }
}
