//
//  WeeklySummaryView.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import SwiftUI
import SwiftData

struct WeeklySummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var weeklySummaries: [WeeklySummary]
    @Query private var journalEntries: [JournalEntry]
    
    @State private var isLoading = false
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView("Loading your summary...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 50)
                    } else if let summary = latestSummary {
                        // Summary header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Week in Review")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("\(formatDate(summary.startDate)) - \(formatDate(summary.endDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Narrative
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.headline)
                            
                            Text(summary.narrative)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Patterns
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Patterns Detected")
                                .font(.headline)
                            
                            ForEach(summary.highlightedPatterns) { pattern in
                                PatternView(pattern: pattern)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                    } else {
                        VStack(spacing: 20) {
                            Text("No weekly summary available")
                                .font(.headline)
                            
                            Text("Generate a summary based on your journal entries from the past week.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button(action: generateSummary) {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Text("Generate Weekly Summary")
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .disabled(isGenerating)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    }
                }
                .padding()
            }
            .navigationTitle("Weekly Summary")
            .onAppear(perform: loadSummary)
            .refreshable {
                loadSummary()
            }
        }
    }
    
    private var latestSummary: WeeklySummary? {
        weeklySummaries.sorted(by: { $0.endDate > $1.endDate }).first
    }
    
    private func loadSummary() {
        isLoading = true
        
        // Data is loaded via @Query, simulate a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if there are any summaries
            if self.weeklySummaries.isEmpty {
                // Create a mock summary if none exists
                let _ = MockDataGenerator.createMockWeeklySummary(modelContext: self.modelContext)
            }
            
            self.isLoading = false
        }
    }
    
    private func generateSummary() {
        isGenerating = true
        
        // Get journal entries from the past week
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        let entries = journalEntries.filter { entry in
            return entry.date >= startDate && entry.date <= endDate
        }
        
        // Generate summary using AIService
        AIService.shared.generateWeeklySummary(from: entries) { narrative, error in
            guard let narrative = narrative, error == nil else {
                print("Error generating summary: \(error?.localizedDescription ?? "Unknown error")")
                isGenerating = false
                return
            }
            
            // Get patterns for common symptoms
            let commonSymptoms = findCommonSymptoms(in: entries)
            var allPatterns: [Pattern] = []
            
            let group = DispatchGroup()
            
            for symptom in commonSymptoms {
                group.enter()
                
                AIService.shared.generatePatternAnalysis(symptom: symptom, entries: entries) { patterns, error in
                    defer { group.leave() }
                    
                    if let patterns = patterns, error == nil {
                        allPatterns.append(contentsOf: patterns)
                    }
                }
            }
            
            group.notify(queue: .main) {
                // Insert the patterns into the model context
                for pattern in allPatterns {
                    self.modelContext.insert(pattern)
                }
                
                // Create and save the weekly summary
                let newSummary = WeeklySummary(
                    startDate: startDate,
                    endDate: endDate,
                    narrative: narrative,
                    highlightedPatterns: allPatterns
                )
                
                self.modelContext.insert(newSummary)
                self.isGenerating = false
            }
        }
    }
    
    private func findCommonSymptoms(in entries: [JournalEntry]) -> [String] {
        // Extract all symptoms
        var symptomCounts: [String: Int] = [:]
        
        for entry in entries {
            for symptom in entry.symptoms {
                symptomCounts[symptom.name, default: 0] += 1
            }
        }
        
        // Return the top 2 most common symptoms
        return symptomCounts.sorted { $0.value > $1.value }.prefix(2).map { $0.key }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct PatternView: View {
    let pattern: Pattern
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pattern.symptomName)
                    .font(.headline)
                
                Spacer()
                
                // Correlation strength indicator
                HStack(spacing: 2) {
                    Text("Correlation:")
                        .font(.caption)
                    
                    Text(strengthText(pattern.correlationStrength))
                        .font(.caption)
                        .foregroundColor(strengthColor(pattern.correlationStrength))
                }
            }
            
            Text(pattern.description)
                .fixedSize(horizontal: false, vertical: true)
            
            // Related factors
            HStack {
                Text("Related factors:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(pattern.relatedFactors, id: \.self) { factor in
                    Text(factor)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func strengthText(_ value: Double) -> String {
        switch value {
            case 0.0..<0.3: return "Weak"
            case 0.3..<0.7: return "Moderate"
            default: return "Strong"
        }
    }
    
    private func strengthColor(_ value: Double) -> Color {
        switch value {
            case 0.0..<0.3: return .orange
            case 0.3..<0.7: return .blue
            default: return .green
        }
    }
}

#Preview {
    WeeklySummaryView()
        .modelContainer(for: [WeeklySummary.self, Pattern.self, JournalEntry.self], inMemory: true)
}
