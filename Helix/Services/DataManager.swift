import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    func syncExercises(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<Exercise>()
        do {
            let existingExercises = try modelContext.fetch(descriptor)
            
            // If empty OR missing new fields (e.g. 'level'), re-seed
            if existingExercises.isEmpty {
                print("No exercises found. Seeding from Bundle...")
                loadAndSave(modelContext: modelContext)
            } else if existingExercises.first?.level == nil {
                print("Detected old data format (missing level). Re-seeding...")
                for ex in existingExercises {
                    modelContext.delete(ex)
                }
                try? modelContext.save()
                loadAndSave(modelContext: modelContext)
            } else {
                print("Exercises already seeded (\(existingExercises.count) items). Skipping.")
            }
        } catch {
            print("Failed to sync exercises: \(error)")
        }
    }
    
    private func loadAndSave(modelContext: ModelContext) {
        let jsonExercises = JSONLoader.shared.loadExercises()
        let baseUrl = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/"
        
        for jsonEx in jsonExercises {
            let description = jsonEx.instructions.joined(separator: "\n\n")
            let primaryMuscle = jsonEx.primaryMuscles.joined(separator: ", ").capitalized
            let secondaryMuscle = jsonEx.secondaryMuscles.joined(separator: ", ").capitalized
            
            let imagePathArray = jsonEx.images.map { baseUrl + $0 }
            
            let newEx = Exercise(
                name: jsonEx.name,
                muscleGroup: primaryMuscle.isEmpty ? nil : primaryMuscle,
                secondaryMuscles: secondaryMuscle.isEmpty ? nil : secondaryMuscle,
                equipment: jsonEx.equipment?.capitalized,
                descriptionText: description,
                imageUrlString: imagePathArray.first,
                images: imagePathArray,
                force: jsonEx.force?.capitalized,
                level: jsonEx.level?.capitalized,
                mechanic: jsonEx.mechanic?.capitalized,
                category: jsonEx.category.capitalized
            )
            modelContext.insert(newEx)
        }
        
        do {
            try modelContext.save()
            print("Successfully seeded \(jsonExercises.count) exercises with full metadata.")
        } catch {
            print("Failed to save seeded exercises: \(error)")
        }
    }
}
