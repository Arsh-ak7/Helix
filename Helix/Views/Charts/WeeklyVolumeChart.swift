import SwiftUI
import Charts
import SwiftData

struct WeeklyVolumeChart: View {
    var workouts: [Workout]
    
    // Group volume by day
    // We only take the top 7 days with data or just the last 7 workout days
    struct DailyVolume: Identifiable {
        let id = UUID()
        let date: Date
        let volume: Double
    }
    
    var chartData: [DailyVolume] {
        let calendar = Calendar.current
        let sortedWorkouts = workouts.sorted { $0.startTime < $1.startTime }
        
        // Group by start of day
        let grouped = Dictionary(grouping: sortedWorkouts) { workout in
            calendar.startOfDay(for: workout.startTime)
        }
        
        var dailyVolumes: [DailyVolume] = []
        for (date, workouts) in grouped {
            let totalVolume = workouts.reduce(0) { $0 + $1.totalVolume }
            dailyVolumes.append(DailyVolume(date: date, volume: totalVolume))
        }
        
        return dailyVolumes.sorted { $0.date < $1.date }.suffix(7).map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Volume")
                .font(.system(.title2, design: .serif))
                .foregroundStyle(Color.primary)
            
            if chartData.isEmpty {
                Text("Complete a workout to see your progress.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color("AppSurface"))
                    .cornerRadius(12)
            } else {
                Chart(chartData) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Volume", data.volume)
                    )
                    .foregroundStyle(Color("AppAccent"))
                    .cornerRadius(4)
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.narrow))
                    }
                }
                .padding()
                .background(Color("AppSurface"))
                .cornerRadius(16)
            }
        }
    }
}
