import SwiftUI
import SwiftData

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    var workout: Workout // Passed in workout to add to
    
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises) { exercise in
                    Button {
                        addExerciseToWorkout(exercise)
                    } label: {
                        HStack {
                            Text(exercise.name)
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    private func addExerciseToWorkout(_ exercise: Exercise) {
        let order = workout.exercises.count
        let newWorkoutExercise = WorkoutExercise(exercise: exercise, orderIndex: order)
        // Add one default set
        let defaultSet = WorkoutSet(weight: 0, reps: 0, orderIndex: 0)
        newWorkoutExercise.sets.append(defaultSet)
        
        // Relationship management
        newWorkoutExercise.workout = workout
        workout.exercises.append(newWorkoutExercise)
        
        dismiss()
    }
}
