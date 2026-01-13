import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()
    
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device.")
            return
        }
        
        guard let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        
        let typesToShare: Set = [bodyMass, activeEnergy, workoutType]
        let typesToRead: Set = [bodyMass, activeEnergy, stepCount, workoutType]
        
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }
    
    func saveWorkout(startDate: Date, endDate: Date, activeEnergyBurned: Double?, totalVolume: Double) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .traditionalStrengthTraining
        configuration.locationType = .indoor
        
        let workoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            workoutBuilder.beginCollection(withStart: startDate) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            workoutBuilder.endCollection(withEnd: endDate) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
        
        // Add metadata
        let metadata: [String: Any] = [
            "TotalVolume": totalVolume
        ]
        _ = try await workoutBuilder.addMetadata(metadata)
        
        // Finish workout
        let workout = try await workoutBuilder.finishWorkout()
        print("Successfully saved workout to HealthKit: \(workout)")
    }
}
