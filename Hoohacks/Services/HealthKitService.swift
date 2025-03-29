//
//  HealthKitService.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import Foundation
import HealthKit

class HealthKitService {
    
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    private let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
    private let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let heartRateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
    
    // Request authorization to access HealthKit data
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Define the types we want to read from HealthKit
        let typesToRead: Set<HKObjectType> = [
            sleepType,
            stepCountType,
            activeEnergyType,
            heartRateType
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // Get sleep hours for a specific day
    func getSleepHours(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        // Implementation would query HealthKit for sleep data
        // For MVP we're using mock data, so we'll simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Return a random number between 5 and 8 hours for demo
            let sleepHours = Double.random(in: 5...8)
            completion(sleepHours, nil)
        }
    }
    
    // Get step count for a specific day
    func getStepCount(for date: Date, completion: @escaping (Int?, Error?) -> Void) {
        // Implementation would query HealthKit for step data
        // For MVP we're using mock data, so we'll simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Return a random number between 3000 and 12000 steps for demo
            let steps = Int.random(in: 3000...12000)
            completion(steps, nil)
        }
    }
    
    // Get active calories for a specific day
    func getActiveCalories(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        // Implementation would query HealthKit for active energy data
        // For MVP we're using mock data, so we'll simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Return a random number between 100 and 500 calories for demo
            let calories = Double.random(in: 100...500)
            completion(calories, nil)
        }
    }
    
    // Get resting heart rate for a specific day
    func getRestingHeartRate(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        // Implementation would query HealthKit for heart rate data
        // For MVP we're using mock data, so we'll simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Return a random number between 60 and 80 bpm for demo
            let heartRate = Double.random(in: 60...80)
            completion(heartRate, nil)
        }
    }
    
    // Fetch all relevant health data for a specific day
    func fetchHealthData(for date: Date, completion: @escaping (Double?, Int?, Double?, Double?) -> Void) {
        var sleepHours: Double?
        var stepCount: Int?
        var activeCalories: Double?
        var restingHeartRate: Double?
        
        let group = DispatchGroup()
        
        // Fetch sleep data
        group.enter()
        getSleepHours(for: date) { hours, _ in
            sleepHours = hours
            group.leave()
        }
        
        // Fetch step count
        group.enter()
        getStepCount(for: date) { steps, _ in
            stepCount = steps
            group.leave()
        }
        
        // Fetch active calories
        group.enter()
        getActiveCalories(for: date) { calories, _ in
            activeCalories = calories
            group.leave()
        }
        
        // Fetch resting heart rate
        group.enter()
        getRestingHeartRate(for: date) { heartRate, _ in
            restingHeartRate = heartRate
            group.leave()
        }
        
        // When all fetches are complete, call the completion handler
        group.notify(queue: .main) {
            completion(sleepHours, stepCount, activeCalories, restingHeartRate)
        }
    }
}
