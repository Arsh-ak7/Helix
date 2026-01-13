//
//  ContentView.swift
//  Helix
//
//  Created by Arsh Kumar on 10.01.26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.doc.horizontal")
                }
            
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
        }
        .tint(Color.primary) // Keep it monochrome/slick
        .task {
            // Sync exercises from API on first launch
            await DataManager.shared.syncExercises(modelContext: modelContext)
            
            // Request HealthKit access
            try? await HealthKitManager.shared.requestAuthorization()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
        .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
