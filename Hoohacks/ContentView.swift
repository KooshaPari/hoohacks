//
//  ContentView.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            JournalEntryView()
                .tabItem {
                    Label("Journal", systemImage: "square.and.pencil")
                }
                .tag(0)
            
            WeeklySummaryView()
                .tabItem {
                    Label("Weekly", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            
            PatternAnalysisView()
                .tabItem {
                    Label("Patterns", systemImage: "puzzlepiece")
                }
                .tag(2)
            
            DoctorVisitPrepView()
                .tabItem {
                    Label("Doctor Visit", systemImage: "stethoscope")
                }
                .tag(3)
        }
        .onAppear {
            setupInitialData()
        }
    }
    
    private func setupInitialData() {
        // Check if we have any data already
        let journalFetchDescriptor = FetchDescriptor<JournalEntry>()
        
        do {
            let journalEntriesCount = try modelContext.fetchCount(journalFetchDescriptor)
            
            // If there are no journal entries, seed with mock data
            if journalEntriesCount == 0 {
                MockDataGenerator.createMockJournalEntries(modelContext: modelContext)
                _ = MockDataGenerator.createMockWeeklySummary(modelContext: modelContext)
                _ = MockDataGenerator.createMockDoctorVisitSummary(modelContext: modelContext)
            }
        } catch {
            print("Error checking for existing data: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            JournalEntry.self,
            Symptom.self,
            WeeklySummary.self,
            Pattern.self,
            DoctorVisitSummary.self,
            SymptomSummary.self
        ], inMemory: true)
}
