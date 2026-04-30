import Foundation

enum MarySource: String, CaseIterable, Identifiable, Codable {
    case brainOnly = "Brain Only"
    case evidenceAndBrain = "Evidence and Brain"
    case projectData = "Project Data"

    var id: String { rawValue }
}
