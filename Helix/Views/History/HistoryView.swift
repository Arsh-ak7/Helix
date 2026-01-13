import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.startTime, order: .reverse) private var allWorkouts: [Workout]
    
    // Group workouts by Month+Year (e.g. "January 2026")
    var groupedWorkouts: [(String, [Workout])] {
        let grouped = Dictionary(grouping: allWorkouts) { workout in
            workout.startTime.formatted(.dateTime.month(.wide).year())
        }
        // Sort keys (months) in descending order by parsing them back to date or using a known order
        // For simplicity, we can rely on the fact that allWorkouts is already sorted. 
        // We just iterate the sorted list and build the groups to maintain order.
        
        var sections: [(String, [Workout])] = []
        var currentSection: String?
        var currentWorkouts: [Workout] = []
        
        for workout in allWorkouts {
            let month = workout.startTime.formatted(.dateTime.month(.wide).year())
            if month != currentSection {
                if let section = currentSection {
                    sections.append((section, currentWorkouts))
                }
                currentSection = month
                currentWorkouts = [workout]
            } else {
                currentWorkouts.append(workout)
            }
        }
        if let section = currentSection {
            sections.append((section, currentWorkouts))
        }
        
        return sections
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if allWorkouts.isEmpty {
                        EmptyHistoryView()
                    } else {
                        ForEach(groupedWorkouts, id: \.0) { (month, workouts) in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(month)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 4)
                                
                                ForEach(workouts) { workout in
                                    NavigationLink {
                                        WorkoutDetailView(workout: workout)
                                    } label: {
                                        HistoryCard(workout: workout)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            modelContext.delete(workout)
                                        } label: {
                                            Label("Delete Workout", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HistoryCard: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            // Date Box
            VStack(spacing: 2) {
                Text(workout.startTime.formatted(.dateTime.day()))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)
                Text(workout.startTime.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 50)
            .padding(.trailing, 12)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(workout.sessionTitle)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(Color.primary)
                
                HStack(spacing: 12) {
                    Label(workout.formattedDuration, systemImage: "clock")
                    Label(String(format: "%.0f kg", workout.totalVolume), systemImage: "dumbbell.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.primary.opacity(0.3))
        }
        .padding(16)
        .background(Color("AppSurface"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "notebook")
                .font(.system(size: 48))
                .foregroundStyle(Color("AppAccent").opacity(0.5))
            Text("Your Journal is Empty")
                .font(.system(.title3, design: .serif))
            Text("Complete your first workout to start your history.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}
