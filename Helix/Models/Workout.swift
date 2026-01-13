import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var notes: String
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise] = []
    
    init(startTime: Date = Date()) {
        self.id = UUID()
        self.startTime = startTime
        self.notes = ""
    }
}


