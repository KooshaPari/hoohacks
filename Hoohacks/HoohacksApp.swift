//
//  HoohacksApp.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import SwiftUI
import SwiftData

@main
struct HoohacksApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            WeeklySummary.self,
            DoctorVisitSummary.self,
            Symptom.self,
            SymptomSummary.self,
            Pattern.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Request HealthKit authorization when the app launches
                    HealthKitService.shared.requestAuthorization { success, error in
                        if success {
                            print("HealthKit authorization successful")
                        } else if let error = error {
                            print("HealthKit authorization failed: \(error.localizedDescription)")
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
