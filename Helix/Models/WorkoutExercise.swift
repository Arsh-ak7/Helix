import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var orderIndex: Int
    
    var exercise: Exercise?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workoutExercise)
    var sets: [WorkoutSet] = []
    
    var workout: Workout?
    
    init(exercise: Exercise, orderIndex: Int) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
    }
}
