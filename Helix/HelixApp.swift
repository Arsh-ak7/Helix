//
//  HelixApp.swift
//  Helix
//
//  Created by Arsh Kumar on 10.01.26.
//

import SwiftUI
import SwiftData

@main
struct HelixApp: App {
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                TimerOverlayView(timerManager: timerManager)
            }
            .environmentObject(timerManager)
        }
        .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self, WorkoutSet.self, Routine.self, RoutineExercise.self])
    }
}
