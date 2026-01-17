import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var timerManager: TimerManager
    @Query(sort: \Workout.startTime, order: .reverse) private var recentWorkouts: [Workout]
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    
    @State private var activeWorkout: Workout?
    @State private var showCreateRoutine = false
    @State private var selectedRoutineToEdit: Routine?
    @State private var routineToDelete: Routine?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Helix")
                                .font(.system(size: 40, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.primary)
                            
                            Text(Date().formatted(date: .complete, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Quick Actions
                        VStack(spacing: 16) {
                            Button {
                                startNewWorkout()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("New Session")
                                            .font(.system(.title3, design: .serif))
                                            .foregroundStyle(Color.primary)
                                        Text("Log your workout")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                        .foregroundStyle(Color("AppAccent"))
                                }
                                .padding(20)
                                .background(Color("AppSurface"))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Templates / Routines
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Routines")
                                    .font(.system(.title2, design: .serif))
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                Button {
                                    showCreateRoutine = true
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.title3)
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                            
                            if routines.isEmpty {
                                Button {
                                    showCreateRoutine = true
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Create your first routine")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color("AppSurface"))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                    )
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(routines) { routine in
                                            Button {
                                                startWorkout(from: routine)
                                            } label: {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    Text(routine.name)
                                                        .font(.system(.headline, design: .serif))
                                                        .foregroundStyle(Color.primary)
                                                        .lineLimit(2)
                                                    
                                                    Text("\(routine.exercises.count) Exercises")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "play.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(Color("AppAccent"))
                                                }
                                                .padding(16)
                                                .frame(width: 140, height: 140)
                                                .background(Color("AppSurface"))
                                                .cornerRadius(16)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                                )
                                                .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                                            }
                                            .contextMenu {
                                                Button {
                                                    selectedRoutineToEdit = routine
                                                } label: {
                                                    Label("Edit Routine", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    routineToDelete = routine
                                                    showDeleteConfirmation = true
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 16) {
                            Text("History")
                                .font(.system(.title2, design: .serif))
                                .foregroundStyle(Color.primary)
                            
                            if recentWorkouts.isEmpty {
                                Text("No workouts yet.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical)
                            } else {
                                ForEach(recentWorkouts.prefix(3)) { workout in
                                    NavigationLink {
                                        WorkoutDetailView(workout: workout)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(workout.startTime.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.headline)
                                                    .fontWeight(.regular)
                                                    .foregroundStyle(Color.primary)
                                                Text("\(workout.exercises.count) Exercises")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .padding()
                                        .background(Color("AppSurface"))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain) // Ensures no default blue tint
                                }
                            }
                        }
                        
                        // Analytics / Charts
                        if !recentWorkouts.isEmpty {
                            WeeklyVolumeChart(workouts: recentWorkouts)
                        }
                    }
                    .padding(24)
                }
            }
            .sheet(isPresented: $showCreateRoutine) {
                CreateRoutineView()
            }
            .sheet(item: $selectedRoutineToEdit) { routine in
                CreateRoutineView(routineToEdit: routine)
            }
            .fullScreenCover(item: $activeWorkout) { workout in
                ZStack {
                    ActiveWorkoutView(workout: workout)
                    TimerOverlayView(timerManager: timerManager)
                }
                .environmentObject(timerManager)
            }
            .alert("Delete Routine?", isPresented: $showDeleteConfirmation, presenting: routineToDelete) { routine in
                Button("Delete", role: .destructive) {
                    deleteRoutine(routine)
                }
                Button("Cancel", role: .cancel) {}
            } message: { routine in
                Text("Are you sure you want to delete '\(routine.name)'? This cannot be undone.")
            }
        }
    }
    
    private func deleteRoutine(_ routine: Routine) {
        modelContext.delete(routine)
    }
    
    private func startNewWorkout() {
        let newWorkout = Workout()
        modelContext.insert(newWorkout)
        activeWorkout = newWorkout
    }
    
    private func startWorkout(from routine: Routine) {
        let newWorkout = Workout()
        
        // Copy exercises from routine
        let sortedRoutineExercises = routine.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })
        for (index, routineEx) in sortedRoutineExercises.enumerated() {
            if let exercise = routineEx.exercise {
                let workoutExercise = WorkoutExercise(
                    exercise: exercise,
                    orderIndex: index,
                    restDuration: routineEx.restDuration ?? 90
                )
                workoutExercise.workout = newWorkout
                
                // Add one initial empty set
                let defaultSet = WorkoutSet(weight: 0, reps: 0, orderIndex: 0)
                defaultSet.workoutExercise = workoutExercise
                workoutExercise.sets.append(defaultSet)
                
                newWorkout.exercises.append(workoutExercise)
            }
        }
        
        modelContext.insert(newWorkout)
        activeWorkout = newWorkout
    }
}

#Preview {
    DashboardView()
        .environmentObject(TimerManager())
        .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self, WorkoutSet.self, Routine.self, RoutineExercise.self], inMemory: true)
}
