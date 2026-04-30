//
//  MaryScreenshotOCRService.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Vision
import AppKit

/// CLEANED: A high-speed Vision bridge.
/// No language correction (which breaks code) and optimized for M2 speed.
final class MaryScreenshotOCRService {
    
    func readText(from cgImage: CGImage) async -> String {
        // Run on a background thread to prevent UI hangs
        return await Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            
            // 🎯 CRITICAL: Disable correction so code variables stay intact.
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false 
            
            // Optimization for the M2 Neural Engine
            request.recognitionLanguages = ["en-US"] 
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                return observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            } catch {
                print("Mary OCR Error: \(error.localizedDescription)")
                return ""
            }
        }.value
    }
}
