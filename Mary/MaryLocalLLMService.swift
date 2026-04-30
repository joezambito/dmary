//
//  MaryLocalLLMService.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation

/// 🛠️ THE MANAGER (Hardware Controller)
/// Cleaned of rules. It just ensures the process exists.
actor MaryBackendManager {
    static let shared = MaryBackendManager()
    private var process: Process?

    func ensureRunning() async -> Bool {
        if await isServerReachable() { return true }
        
        if process?.isRunning != true {
            startBackend()
        }
        
        for _ in 0..<10 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if await isServerReachable() { return true }
        }
        return false
    }

    private func isServerReachable() async -> Bool {
        guard let url = URL(string: "http://127.0.0.1:8082/health") else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1
        let (_, response) = (try? await URLSession.shared.data(for: request)) ?? (Data(), nil)
        return (response as? HTTPURLResponse)?.statusCode == 200
    }

    private func startBackend() {
        let scriptPath = "/Users/joezambito/Mary/start_mary_backend.sh"
        guard FileManager.default.fileExists(atPath: scriptPath) else { return }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["--login", scriptPath]
        task.standardInput = Pipe()
        task.standardOutput = Pipe()
        task.standardError = Pipe()
        
        try? task.run()
        process = task
    }
}

/// 🚀 THE SERVICE (The Hardware Interface)
/// This file NO LONGER decides the rules. It just sends the data.
struct MaryLocalLLMService {

    func generateResponse(prompt: String, maxTokens: Int = 1000, temp: Double = 0.05) async -> String {
        let backendReady = await MaryBackendManager.shared.ensureRunning()
        guard backendReady else { return "BACKEND_ERROR: Server Not Reachable" }

        // FIXED: OpenAI-compatible llama.cpp endpoint
        guard let url = URL(string: "http://127.0.0.1:8082/v1/chat/completions") else {
            return "BACKEND_ERROR: Invalid URL."
        }

        let body: [String: Any] = [
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": maxTokens,
            "temperature": temp,
            "stop": ["<|im_end|>", "```", "Joe:", "Mary:"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 200
        let session = URLSession(configuration: config)

        do {
            let (data, _) = try await session.data(for: request)

            if
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let first = choices.first,
                let message = first["message"] as? [String: Any],
                let content = message["content"] as? String
            {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            return "BACKEND_ERROR: Invalid Response"
        } catch {
            return "BACKEND_ERROR: \(error.localizedDescription)"
        }
    }
}
