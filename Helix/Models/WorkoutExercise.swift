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
    
    var restDuration: Int = 90
    
    init(exercise: Exercise, orderIndex: Int, restDuration: Int = 90) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
        self.restDuration = restDuration
    }
}
