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
    
    var targetSets: Int? = 3
    var targetReps: String? = "10"
    var restDuration: Int? = 90
    
    init(exercise: Exercise, orderIndex: Int, targetSets: Int = 3, targetReps: String = "10", restDuration: Int = 90) {
        self.id = UUID()
        self.exercise = exercise
        self.orderIndex = orderIndex
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.restDuration = restDuration
    }
}
