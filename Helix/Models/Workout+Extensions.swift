import Foundation

extension Workout {
    /// Total duration in seconds
    var duration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }
    
    /// Total volume (Weight * Reps) for all completed sets
    var totalVolume: Double {
        exercises.reduce(0.0) { result, exercise in
            let exerciseVolume = exercise.sets.filter { $0.isCompleted }.reduce(0.0) { setVol, set in
                setVol + (set.weight * Double(set.reps))
            }
            return result + exerciseVolume
        }
    }
    
    /// Formatted Duration String (e.g., "1h 15m" or "45m")
    var formattedDuration: String {
        let seconds = Int(duration)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Auto-generated Title based on time of day
    var sessionTitle: String {
        let hour = Calendar.current.component(.hour, from: startTime)
        switch hour {
        case 5..<12: return "Morning Session"
        case 12..<17: return "Afternoon Session"
        case 17..<22: return "Evening Session"
        default: return "Night Session"
        }
    }
}
