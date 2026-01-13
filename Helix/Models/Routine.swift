import Foundation
import SwiftData

@Model
final class Routine {
    var id: UUID
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \RoutineExercise.routine)
    var exercises: [RoutineExercise] = []
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}

@Model
final class RoutineExercise {
    var id: UUID
    var orderIndex: Int
    var exercise: Exercise? // Reference to the master exercise
    var routine: Routine?
    
    // We only need to store the target sets/reps structure, typically we just store the list of exercises for now.
    // Enhanced version could store "Target Sets/Reps".
    
    init(exercise: Exercise, orderIndex: Int) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
    }
}
