import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    func syncExercises(modelContext: ModelContext) async {
        let descriptor = FetchDescriptor<Exercise>()
        do {
            let existingExercises = try modelContext.fetch(descriptor)
            
            // For this prototype update, if we have exercises but they might be old versions,
            // let's clear them to get the new images/descriptions.
            // In a production app, we would check for updates or versioning.
            if existingExercises.isEmpty {
                await fetchAndSave(modelContext: modelContext)
            } else {
                 // Check if we have data with images (rudimentary check for 'v2' data)
                 // If the first exercise has no description, we probably need to re-sync.
                 if existingExercises.first?.descriptionText == nil {
                     print("Detected old data format. Re-syncing...")
                     for ex in existingExercises {
                         modelContext.delete(ex)
                     }
                     try modelContext.save() // Commit deletion
                     await fetchAndSave(modelContext: modelContext)
                 }
            }
        } catch {
            print("Failed to sync exercises: \(error)")
        }
    }
    
    private func fetchAndSave(modelContext: ModelContext) async {
        do {
            let apiExercises = try await APIService.shared.fetchExercises()
            for apiEx in apiExercises {
                let cleanDescription = apiEx.description?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                
                let newEx = Exercise(
                    name: apiEx.name,
                    muscleGroup: nil,
                    equipment: nil,
                    descriptionText: cleanDescription,
                    imageUrlString: apiEx.mainImageUrl
                )
                modelContext.insert(newEx)
            }
            try modelContext.save()
            print("Synced \(apiExercises.count) exercises with details.")
        } catch {
            print("API Fetch failed: \(error)")
        }
    }
}
