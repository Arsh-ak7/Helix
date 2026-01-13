import SwiftUI
import SwiftData

struct CreateRoutineView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    
    @State private var routineName = ""
    @State private var selectedExercises: Set<Exercise> = []
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Routine Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    TextField("e.g. Push Day", text: $routineName)
                        .font(.system(.title3, design: .serif))
                        .padding()
                        .background(Color("AppSurface"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                }
                .padding()
                
                // Exercise Selection
                List {
                    Section("Select Exercises") {
                        ForEach(filteredExercises) { exercise in
                            HStack {
                                Text(exercise.name)
                                    .font(.body)
                                Spacer()
                                if selectedExercises.contains(exercise) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("AppAccent"))
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(for: exercise)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search exercises")
                .scrollContentBackground(.hidden) // Cleaner look
            }
            .background(Color("AppBackground"))
            .navigationTitle("New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .disabled(routineName.isEmpty || selectedExercises.isEmpty)
                }
            }
        }
    }
    
    private func toggleSelection(for exercise: Exercise) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }
    
    private func saveRoutine() {
        let newRoutine = Routine(name: routineName)
        
        // Add exercises in alphabetical order (or user selection order if we tracked it, but alpha is fine for v1)
        // Actually, normally users pick typically in order. But Set is unordered. 
        // Let's just sort by name for now to be deterministic.
        let sortedSelection = selectedExercises.sorted { $0.name < $1.name }
        
        for (index, exercise) in sortedSelection.enumerated() {
            let routineExercise = RoutineExercise(exercise: exercise, orderIndex: index)
            routineExercise.routine = newRoutine
            newRoutine.exercises.append(routineExercise)
        }
        
        modelContext.insert(newRoutine)
        dismiss()
    }
}

#Preview {
    CreateRoutineView()
        .modelContainer(for: [Routine.self, Exercise.self, RoutineExercise.self], inMemory: true)
}
