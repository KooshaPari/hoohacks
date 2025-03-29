//
//  PatternAnalysisView.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import SwiftUI
import SwiftData

struct PatternAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var journalEntries: [JournalEntry]
    @Query private var allPatterns: [Pattern]
    
    @State private var selectedSymptom: String = "Headache"
    @State private var patterns: [Pattern] = []
    @State private var isLoading = false
    
    // Available symptoms for selection
    private let availableSymptoms = [
        "Headache",
        "Fatigue",
        "Nausea",
        "Digestive Issues",
        "Anxiety",
        "Low Mood"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Symptom selector
                Picker("Select symptom", selection: $selectedSymptom) {
                    ForEach(availableSymptoms, id: \.self) { symptom in
                        Text(symptom).tag(symptom)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.gray.opacity(0.1))
                
                if isLoading {
                    ProgressView("Analyzing patterns...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                } else if patterns.isEmpty {
                    VStack(spacing: 20) {
                        Text("No pattern analysis available for \(selectedSymptom)")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text("Analyze your journal entries to identify patterns related to this symptom.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button(action: analyzePatterns) {
                            Text("Analyze Patterns")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Pattern Analysis: \(selectedSymptom)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top)
                                .padding(.horizontal)
                            
                            ForEach(patterns) { pattern in
                                PatternDetailView(pattern: pattern)
                                    .padding(.horizontal)
                            }
                            
                            PatternInsightsView(patterns: patterns)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Pattern Analysis")
            .onChange(of: selectedSymptom) { _ in
                loadPatterns()
            }
            .onAppear {
                loadPatterns()
            }
        }
    }
    
    private func loadPatterns() {
        isLoading = true
        
        // Filter patterns for the selected symptom
        patterns = allPatterns.filter { $0.symptomName == selectedSymptom }
        isLoading = false
    }
    
    private func analyzePatterns() {
        isLoading = true
        
        // Get entries with the selected symptom
        let entries = journalEntries.filter { entry in
            entry.symptoms.contains(where: { $0.name.lowercased() == selectedSymptom.lowercased() })
        }
        
        // Generate pattern analysis using AIService
        AIService.shared.generatePatternAnalysis(symptom: selectedSymptom, entries: journalEntries) { newPatterns, error in
            DispatchQueue.main.async {
                if let newPatterns = newPatterns, error == nil {
                    // Clear existing patterns for this symptom
                    for pattern in allPatterns.filter({ $0.symptomName == selectedSymptom }) {
                        modelContext.delete(pattern)
                    }
                    
                    // Insert new patterns
                    for pattern in newPatterns {
                        modelContext.insert(pattern)
                    }
                    
                    patterns = newPatterns
                } else {
                    print("Error generating patterns: \(error?.localizedDescription ?? "Unknown error")")
                    // For demo, use mock data if real analysis fails
                    let mockPatterns = [
                        Pattern(
                            symptomName: self.selectedSymptom,
                            description: "You averaged 5.8 hours of sleep on symptom days vs. 7.3 hours on symptom-free days",
                            correlationStrength: 0.85,
                            relatedFactors: ["Sleep", "Stress"]
                        ),
                        Pattern(
                            symptomName: self.selectedSymptom,
                            description: "You tagged 'skipped meals' on 90% of symptom days vs. 10% of symptom-free days",
                            correlationStrength: 0.9,
                            relatedFactors: ["Nutrition", "Meal timing"]
                        ),
                        Pattern(
                            symptomName: self.selectedSymptom,
                            description: "Your step count averaged 4,000 on symptom days vs. 8,500 on symptom-free days",
                            correlationStrength: 0.7,
                            relatedFactors: ["Physical activity", "Sedentary behavior"]
                        )
                    ]
                    
                    // Insert mock patterns
                    for pattern in mockPatterns {
                        modelContext.insert(pattern)
                    }
                    
                    patterns = mockPatterns
                }
                self.isLoading = false
            }
        }
    }
}

struct PatternDetailView: View {
    let pattern: Pattern
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(pattern.description)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack {
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
                
                Spacer()
                
                // Correlation strength indicator
                CircularProgressView(progress: pattern.correlationStrength)
                    .frame(width: 50, height: 50)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PatternInsightsView: View {
    let patterns: [Pattern]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Insights & Recommendations")
                .font(.headline)
            
            Text("Based on the patterns identified, consider:")
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(generateRecommendations(), id: \.self) { recommendation in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text(recommendation)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            
            Text("**Note:** These observations are based on correlations only, not causation. Discuss these patterns with your healthcare provider.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        
        // Generate recommendations based on detected patterns
        for pattern in patterns {
            if pattern.description.contains("sleep") {
                recommendations.append("Aim for 7-8 hours of sleep, especially during high-risk periods")
            }
            
            if pattern.description.contains("skipped meals") {
                recommendations.append("Maintain regular eating patterns and avoid skipping meals")
            }
            
            if pattern.description.contains("step count") || pattern.description.contains("physical activity") {
                recommendations.append("Incorporate regular, moderate physical activity into your daily routine")
            }
            
            if pattern.relatedFactors.contains("Stress") {
                recommendations.append("Practice stress management techniques such as deep breathing or mindfulness")
            }
        }
        
        // If no specific recommendations, add general ones
        if recommendations.isEmpty {
            recommendations = [
                "Track your symptoms consistently to identify more patterns",
                "Pay attention to potential triggers in your daily routine",
                "Consider discussing these patterns with a healthcare provider"
            ]
        }
        
        return recommendations
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor(progress))
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .bold()
        }
    }
    
    private func progressColor(_ value: Double) -> Color {
        switch value {
        case 0.0..<0.3: return .orange
        case 0.3..<0.7: return .blue
        default: return .green
        }
    }
}

#Preview {
    PatternAnalysisView()
        .modelContainer(for: [Pattern.self, JournalEntry.self], inMemory: true)
}
