import Foundation

/// A structured container for generated Swift code.
struct MaryCodePackage: Identifiable {
    let id = UUID()
    let fileName: String
    let code: String
    let timestamp = Date()
}

/// CLEANED: A passive bridge for code output.
/// It does not 'think' about the code; it only packages it for the UI/System.
struct MarySwiftCodeWriter {

    /// CLEANED: Takes raw code from the Brain and packages it.
    /// Logic for naming files or formatting now lives in the Main Brain.
    func package(code: String, as fileName: String) -> MaryCodePackage {
        return MaryCodePackage(
            fileName: fileName.hasSuffix(".swift") ? fileName : "\(fileName).swift",
            code: code
        )
    }
}
