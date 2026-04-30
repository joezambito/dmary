//
//  MaryFileReader.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//


import Foundation
import Vision
import PDFKit

#if canImport(AppKit)
import AppKit
#endif

struct MaryReadFile: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: String
    let content: String
}

/// THE SENSORY INPUT: Converts diverse file formats into clean text for the LLM.
enum MaryFileReader {

    static func readFile(from url: URL) async -> MaryReadFile? {
        let name = url.lastPathComponent
        let ext = url.pathExtension.lowercased()

        // 📝 Handle Text/Code
        if isTextFile(ext) {
            return MaryReadFile(
                name: name,
                type: ext,
                content: readText(url) ?? "Error: File unreadable."
            )
        }

        // 🖼️ Handle Screenshots (OCR)
        if isImageFile(ext) {
            let text = await readImageText(url)
            return MaryReadFile(name: name, type: "image", content: text)
        }

        // 📄 Handle Documentation (PDF)
        if ext == "pdf" {
            let text = readPDFText(url)
            return MaryReadFile(name: name, type: "pdf", content: text)
        }

        return MaryReadFile(name: name, type: ext, content: "Binary or unsupported format.")
    }

    private static func readText(_ url: URL) -> String? {
        do {
            let access = url.startAccessingSecurityScopedResource()
            defer {
                if access {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            return nil
        }
    }

    /// Optimized OCR for M2 Pro Neural Engine.
    private static func readImageText(_ url: URL) async -> String {
        await withCheckedContinuation { continuation in
            #if os(macOS)
            guard let image = NSImage(contentsOf: url),
                  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                continuation.resume(returning: "")
                return
            }

            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                continuation.resume(returning: text)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false

            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            #else
            continuation.resume(returning: "")
            #endif
        }
    }

    private static func readPDFText(_ url: URL) -> String {
        guard let pdf = PDFDocument(url: url) else {
            return "Could not parse PDF."
        }

        var fullText = ""

        for i in 0..<min(pdf.pageCount, 5) {
            if let pageText = pdf.page(at: i)?.string {
                fullText += pageText + "\n"
            }
        }

        return fullText
    }

    private static func isTextFile(_ ext: String) -> Bool {
        [
            "txt", "md", "swift", "json", "xml", "html", "css",
            "js", "ts", "py", "java", "c", "cpp", "h", "hpp",
            "log", "csv", "yaml", "yml"
        ].contains(ext)
    }

    private static func isImageFile(_ ext: String) -> Bool {
        ["png", "jpg", "jpeg", "heic", "tiff", "bmp"].contains(ext)
    }
}
