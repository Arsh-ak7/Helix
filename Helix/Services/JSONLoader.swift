import Foundation

struct JSONExercise: Codable {
    let name: String
    let force: String?
    let level: String?
    let mechanic: String?
    let equipment: String?
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let category: String
    let images: [String]
    let id: String? // Some datasets use 'id', others just name. We'll make it optional.
}

class JSONLoader {
    static let shared = JSONLoader()
    
    func loadExercises() -> [JSONExercise] {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("❌ exercises.json not found in Bundle.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let exercises = try decoder.decode([JSONExercise].self, from: data)
            return exercises
        } catch {
            print("❌ Error decoding exercises.json: \(error)")
            return []
        }
    }
}
