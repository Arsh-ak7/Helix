import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var orderIndex: Int
    
    // New Fields
    var rpe: Int?
    var setType: String? // "Normal", "Warmup", "Drop", "Failure"
    
    var workoutExercise: WorkoutExercise?
    
    init(weight: Double, reps: Int, orderIndex: Int, setType: String = "Normal") {
        self.id = UUID()
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
        self.orderIndex = orderIndex
        self.setType = setType
        self.rpe = nil
    }
}
