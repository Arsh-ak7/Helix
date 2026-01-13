import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isActive: Bool = false
    @Published var totalDuration: TimeInterval = 0
    
    private var timer: AnyCancellable?
    private var endDate: Date?
    
    func startTimer(duration: TimeInterval) {
        self.totalDuration = duration
        self.timeRemaining = duration
        self.isActive = true
        self.endDate = Date().addingTimeInterval(duration)
        
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stopTimer() {
        isActive = false
        timeRemaining = 0
        timer?.cancel()
        endDate = nil
    }
    
    func addTime(_ seconds: TimeInterval) {
        guard isActive, let endDate = endDate else { return }
        self.endDate = endDate.addingTimeInterval(seconds)
        self.totalDuration += seconds
        tick() // update immediately
    }
    
    private func tick() {
        guard let endDate = endDate else { return }
        let remaining = endDate.timeIntervalSinceNow
        
        if remaining <= 0 {
            stopTimer()
            // In a real app, play a sound or vibration here
        } else {
            self.timeRemaining = remaining
        }
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1 - (timeRemaining / totalDuration)
    }
}
