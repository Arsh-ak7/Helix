import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var showingSaveAlert = false
    @State private var routineName = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // ... (Existing Header and Content)
                // Header Stats
                VStack(alignment: .leading, spacing: 12) {
                    Text(workout.startTime.formatted(date: .long, time: .omitted))
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                    
                    Text(workout.sessionTitle)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.primary)
                    
                    HStack(spacing: 24) {
                        StatPill(icon: "clock", value: workout.formattedDuration, label: "Duration")
                        StatPill(icon: "dumbbell.fill", value: String(format: "%.0f kg", workout.totalVolume), label: "Volume")
                        StatPill(icon: "list.bullet", value: "\(workout.exercises.count)", label: "Exercises")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                
                // Exercise List
                VStack(spacing: 24) {
                    if workout.exercises.isEmpty {
                        Text("No exercises recorded.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    } else {
                        ForEach(workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                            ReadOnlyExerciseCard(workoutExercise: exercise)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color("AppBackground"))
        .navigationTitle("")
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    routineName = workout.sessionTitle // Default name
                    showingSaveAlert = true
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
        .alert("Save as Routine", isPresented: $showingSaveAlert) {
            TextField("Routine Name", text: $routineName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveRoutine()
            }
        } message: {
            Text("Create a reusable template from this workout.")
        }
    }
    
    private func saveRoutine() {
        let newRoutine = Routine(name: routineName)
        
        // Copy exercises structure
        let sortedExercises = workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })
        for (index, workoutExercise) in sortedExercises.enumerated() {
            if let baseExercise = workoutExercise.exercise {
                let routineExercise = RoutineExercise(exercise: baseExercise, orderIndex: index)
                routineExercise.routine = newRoutine
                newRoutine.exercises.append(routineExercise)
            }
        }
        
        modelContext.insert(newRoutine)
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                Text(label)
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.system(.headline, design: .monospaced))
                .foregroundStyle(Color.primary)
        }
    }
}

struct ReadOnlyExerciseCard: View {
    let workoutExercise: WorkoutExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(workoutExercise.exercise?.name ?? "Unknown")
                .font(.system(.title3, design: .serif))
                .fontWeight(.medium)
            
            // Sets Table
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("SET").frame(width: 40, alignment: .leading)
                    Spacer()
                    Text("KG").frame(width: 60, alignment: .trailing)
                    Text("REPS").frame(width: 60, alignment: .trailing)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
                
                ForEach(workoutExercise.sets.sorted(by: { $0.orderIndex < $1.orderIndex })) { set in
                    HStack {
                        Text("\(set.orderIndex + 1)")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .leading)
                        
                        Spacer()
                        
                        Text(set.weight.formatted())
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 60, alignment: .trailing)
                        
                        Text("\(set.reps)")
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .overlay(alignment: .bottom) {
                        if set.id != workoutExercise.sets.sorted(by: {$0.orderIndex < $1.orderIndex}).last?.id {
                            Divider().opacity(0.3)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color("AppSurface"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}
