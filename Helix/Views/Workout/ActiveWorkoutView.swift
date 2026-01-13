import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Bindable var workout: Workout
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timerManager: TimerManager
    
    @State private var showExerciseSelection = false
    @FocusState private var focusedField: UUID?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if workout.exercises.isEmpty {
                        Text("No exercises yet.")
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(.secondary)
                            .padding(.top, 60)
                    }
                    
                    ForEach(workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { workoutExercise in
                        ExerciseCard(workoutExercise: workoutExercise, focusedField: $focusedField)
                    }
                    
                    Button(action: { showExerciseSelection = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Exercise")
                                .font(.system(.body, design: .serif))
                        }
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AppSurface"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    Button(action: { finishWorkout() }) {
                        Text("Finish Session")
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color("AppBackground")) // Text color matches background (cream/dark)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primary) // Button is solid Black (light) or White (dark)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding(.top)
            }
            .background(Color("AppBackground"))
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Session")
                        .font(.system(.headline, design: .serif))
                }
                ToolbarItem(placement: .primaryAction) {
                     Button {
                         focusedField = nil
                         timerManager.startTimer(duration: 90)
                     } label: {
                         Image(systemName: "timer")
                             .foregroundStyle(Color.primary)
                     }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        deleteWorkout()
                    }
                    .foregroundStyle(.red.opacity(0.8))
                    .font(.system(.body, design: .serif))
                }
            }
            .sheet(isPresented: $showExerciseSelection) {
                ExerciseSelectionView(workout: workout)
            }
        }
    }
    
    private func finishWorkout() {
        timerManager.stopTimer()
        workout.endTime = Date()
        
        // Sync to HealthKit
        let startTime = workout.startTime
        let endTime = workout.endTime ?? Date()
        let volume = workout.totalVolume
        
        Task {
            // In a real app, calculate actual calories. For now passing nil (HealthKit calculates based on duration/type).
            try? await HealthKitManager.shared.saveWorkout(startDate: startTime, endDate: endTime, activeEnergyBurned: nil, totalVolume: volume)
        }
        
        dismiss()
    }
    
    private func deleteWorkout() {
        modelContext.delete(workout)
        dismiss()
    }
}

struct ExerciseCard: View {
    @Bindable var workoutExercise: WorkoutExercise
    @Environment(\.modelContext) var modelContext // Added modelContext
    @EnvironmentObject var timerManager: TimerManager
    @State private var showDetails = false
    var focusedField: FocusState<UUID?>.Binding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ... (Title Header remains same)
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown")
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.medium)
                
                Spacer()
                
                Button {
                    showDetails = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $showDetails) {
                if let exercise = workoutExercise.exercise {
                    ExerciseDetailView(exercise: exercise)
                        .presentationDetents([.medium, .large])
                }
            }
            
            // Sets Header
            HStack(spacing: 16) {
                Text("Set").frame(width: 40, alignment: .leading)
                Spacer()
                Text("kg").frame(width: 80, alignment: .center)
                Text("Reps").frame(width: 80, alignment: .center)
            }
            .font(.caption)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
            .padding(.trailing, 16)
            
            ForEach(workoutExercise.sets.sorted(by: { $0.orderIndex < $1.orderIndex })) { set in
                SetRow(set: set, index: set.orderIndex + 1, focusedField: focusedField) {
                    deleteSet(set)
                }
                
                if set.id != workoutExercise.sets.sorted(by: {$0.orderIndex < $1.orderIndex}).last?.id {
                     Divider().opacity(0.5)
                }
            }
            
            Button {
                focusedField.wrappedValue = nil // Dismiss keyboard
                addSet()
                timerManager.startTimer(duration: 90)
            } label: {
                Text("Add Set")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(.top, 8)
        }
        // ... (styling remains same)
        .padding(20)
        .background(Color("AppSurface"))
        .cornerRadius(16)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                .padding(.horizontal)
        )
    }
    
    private func addSet() {
        let sortedSets = workoutExercise.sets.sorted(by: { $0.orderIndex < $1.orderIndex })
        let nextIndex = sortedSets.count
        
        // Auto-fill from previous set if it exists
        let lastSet = sortedSets.last
        let newWeight = lastSet?.weight ?? 0
        let newReps = lastSet?.reps ?? 0
        
        let newSet = WorkoutSet(weight: newWeight, reps: newReps, orderIndex: nextIndex)
        newSet.workoutExercise = workoutExercise
        workoutExercise.sets.append(newSet)
    }
    
    private func deleteSet(_ set: WorkoutSet) {
        if let index = workoutExercise.sets.firstIndex(where: { $0.id == set.id }) {
            workoutExercise.sets.remove(at: index)
            modelContext.delete(set)
        }
    }
}

struct SetRow: View {
    @Bindable var set: WorkoutSet
    let index: Int
    var focusedField: FocusState<UUID?>.Binding
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Toggle
            Button {
                set.isCompleted.toggle()
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.isCompleted ? Color("AppAccent") : Color.secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            Text("\(index)")
                .font(.system(.body, design: .monospaced))
                .frame(width: 30, alignment: .center)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            TextField("-", value: $set.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .focused(focusedField, equals: set.id)
                .font(.system(.body, design: .monospaced))
                .padding(.vertical, 10)
                .frame(width: 70)
                .background(Color("AppBackground"))
                .cornerRadius(8)
                .opacity(set.isCompleted ? 0.6 : 1.0) // Dim if completed
            
            TextField("-", value: $set.reps, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .focused(focusedField, equals: set.id)
                .font(.system(.body, design: .monospaced))
                .padding(.vertical, 10)
                .frame(width: 70)
                .background(Color("AppBackground"))
                .cornerRadius(8)
                .opacity(set.isCompleted ? 0.6 : 1.0)

            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(Color.red.opacity(0.6))
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.trailing, 8)
        .padding(.vertical, 4)
    }
}
