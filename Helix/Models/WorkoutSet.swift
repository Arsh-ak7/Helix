import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var orderIndex: Int
    
    var workoutExercise: WorkoutExercise?
    
    init(weight: Double, reps: Int, orderIndex: Int) {
        self.id = UUID()
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
        self.orderIndex = orderIndex
    }
}
