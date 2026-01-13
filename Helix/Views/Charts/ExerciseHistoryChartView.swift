import SwiftUI
import Charts
import SwiftData

struct ExerciseHistoryChartView: View {
    let exercise: Exercise
    @Query private var allWorkouts: [Workout]
    
    // Data Point Struct
    struct DataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let oneRepMax: Double
    }
    
    var chartData: [DataPoint] {
        var points: [DataPoint] = []
        
        // Find all workouts that contain this exercise
        // In a real app with large data, this query should be optimized via FetchDescriptor predicates
        // But for <10k items, memory filtering is acceptable
        
        let sortedWorkouts = allWorkouts.sorted(by: { $0.startTime < $1.startTime })
        
        for workout in sortedWorkouts {
            // Find if this workout has the exercise
            if let workoutExercise = workout.exercises.first(where: { $0.exercise?.id == exercise.id }) {
                // Calculate max 1RM for this session
                var max1RM: Double = 0
                
                for set in workoutExercise.sets where set.isCompleted {
                    // Epley Formula: w * (1 + r/30)
                    let epley = set.weight * (1 + Double(set.reps) / 30.0)
                    if epley > max1RM {
                        max1RM = epley
                    }
                }
                
                if max1RM > 0 {
                    points.append(DataPoint(date: workout.startTime, oneRepMax: max1RM))
                }
            }
        }
        
        return points
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estimated 1RM Progression")
                .font(.headline)
                .fontDesign(.serif)
            
            if chartData.isEmpty {
                Text("Not enough data yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color("AppSurface"))
                    .cornerRadius(12)
            } else {
                Chart {
                    ForEach(chartData) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("1RM", point.oneRepMax)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color("AppAccent"))
                        .symbol {
                            Circle()
                                .fill(Color("AppAccent"))
                                .frame(width: 6, height: 6)
                        }
                        
                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("1RM", point.oneRepMax)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppAccent").opacity(0.3), Color("AppAccent").opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 200)
                .padding()
                .background(Color("AppSurface"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
            }
        }
    }
}
