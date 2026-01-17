import SwiftUI
import SwiftData

struct CreateRoutineView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Exercise.name) var exercises: [Exercise]
    
    // Optional routine to edit
    var routineToEdit: Routine?
    
    @State private var routineName = ""
    @State private var searchText = ""
    
    // Local state for the routine being built/edited
    struct RoutineItem: Identifiable, Equatable {
        let id = UUID()
        var exercise: Exercise
        var targetSets: Int
        var targetReps: String
        var restDuration: Int
    }
    
    @State private var routineItems: [RoutineItem] = []
    
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
                
                List {
                    // Sequence (Selected Exercises)
                    if !routineItems.isEmpty {
                        Section("Sequence") {
                            ForEach($routineItems) { $item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(item.exercise.name)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "line.3.horizontal")
                                            .foregroundStyle(.tertiary)
                                    }
                                    
                                    HStack {
                                        HStack(spacing: 4) {
                                            Text("Sets")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            TextField("3", value: $item.targetSets, format: .number)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 30)
                                                .padding(4)
                                                .background(Color("AppSurface"))
                                                .cornerRadius(6)
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Text("Reps")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            TextField("10", text: $item.targetReps)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 40)
                                                .padding(4)
                                                .background(Color("AppSurface"))
                                                .cornerRadius(6)
                                        }
                                        
                                        HStack(spacing: 4) {
                                            Text("Rest (s)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            TextField("90", value: $item.restDuration, format: .number)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 40)
                                                .padding(4)
                                                .background(Color("AppSurface"))
                                                .cornerRadius(6)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onMove(perform: moveItem)
                            .onDelete(perform: deleteItem)
                        }
                    }
                    
                    // Library (Available Exercises)
                    Section("Library") {
                        ForEach(filteredExercises) { exercise in
                            HStack {
                                Text(exercise.name)
                                    .font(.body)
                                Spacer()
                                if isSelected(exercise) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("AppAccent"))
                                } else {
                                    Image(systemName: "plus.circle")
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
                .scrollContentBackground(.hidden)
            }
            .background(Color("AppBackground"))
            .navigationTitle(routineToEdit == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .disabled(routineName.isEmpty || routineItems.isEmpty)
                }
            }
            .onAppear {
                if let routine = routineToEdit {
                    routineName = routine.name
                    // Load existing exercises
                    // Sort by orderIndex to preserve sequence
                    let sorted = routine.exercises.sorted { $0.orderIndex < $1.orderIndex }
                    routineItems = sorted.compactMap { re in
                        guard let ex = re.exercise else { return nil }
                        return RoutineItem(
                            exercise: ex,
                            targetSets: re.targetSets ?? 3,
                            targetReps: re.targetReps ?? "10",
                            restDuration: re.restDuration ?? 90
                        )
                    }
                }
            }
        }
    }
    
    private func isSelected(_ exercise: Exercise) -> Bool {
        routineItems.contains { $0.exercise.id == exercise.id }
    }
    
    private func moveItem(from source: IndexSet, to destination: Int) {
        routineItems.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteItem(at offsets: IndexSet) {
        routineItems.remove(atOffsets: offsets)
    }
    
    private func toggleSelection(for exercise: Exercise) {
        if let index = routineItems.firstIndex(where: { $0.exercise.id == exercise.id }) {
            routineItems.remove(at: index)
        } else {
            // Default new item
            routineItems.append(RoutineItem(exercise: exercise, targetSets: 3, targetReps: "10", restDuration: 90))
        }
    }
    
    private func saveRoutine() {
        let routine: Routine
        
        if let existing = routineToEdit {
            routine = existing
            routine.name = routineName
            // Clear existing relationships safely?
            // SwiftData relationships can be tricky. Easiest is to delete old RoutineExercises and create new ones.
            // Or update existing ones. Deleting is cleaner for reordering.
            
            // Delete all existing RoutineExercise objects associated with this routine
            for oldRe in routine.exercises {
                modelContext.delete(oldRe)
            }
            routine.exercises.removeAll()
            
        } else {
            routine = Routine(name: routineName)
            modelContext.insert(routine)
        }
        
        for (index, item) in routineItems.enumerated() {
            let routineExercise = RoutineExercise(
                exercise: item.exercise,
                orderIndex: index,
                targetSets: item.targetSets,
                targetReps: item.targetReps,
                restDuration: item.restDuration
            )
            routineExercise.routine = routine
            routine.exercises.append(routineExercise)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CreateRoutineView()
        .modelContainer(for: [Routine.self, Exercise.self, RoutineExercise.self], inMemory: true)
}