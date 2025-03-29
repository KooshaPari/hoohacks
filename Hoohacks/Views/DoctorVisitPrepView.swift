//
//  DoctorVisitPrepView.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import SwiftUI
import SwiftData

struct DoctorVisitPrepView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var doctorVisitSummaries: [DoctorVisitSummary]
    @Query private var journalEntries: [JournalEntry]
    
    @State private var selectedDateRange: DateRange = .month
    @State private var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var customEndDate: Date = Date()
    @State private var questions: [String] = [""]
    @State private var isGenerating = false
    @State private var showExportOptions = false
    @State private var selectedExportOption: ExportOption? = nil
    
    enum DateRange: String, CaseIterable, Identifiable {
        case week = "Last Week"
        case month = "Last Month"
        case threeMonths = "Last 3 Months"
        case custom = "Custom Range"
        
        var id: String { self.rawValue }
    }
    
    enum ExportOption: String, Identifiable {
        case text = "Share as Text"
        case print = "Print"
        
        var id: String { self.rawValue }
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let (start, end) = getDateRange()
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date range selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Time Period")
                            .font(.headline)
                        
                        Picker("Date Range", selection: $selectedDateRange) {
                            ForEach(DateRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        if selectedDateRange == .custom {
                            HStack {
                                DatePicker("From", selection: $customStartDate, displayedComponents: .date)
                                    .labelsHidden()
                                
                                Text("to")
                                
                                DatePicker("To", selection: $customEndDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                        }
                        
                        Text("Summary period: \(dateRangeText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Questions for doctor
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Questions for Your Doctor")
                            .font(.headline)
                        
                        ForEach(0..<questions.count, id: \.self) { index in
                            HStack {
                                TextField("Enter question", text: $questions[index])
                                    .padding(10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(5)
                                
                                if questions.count > 1 {
                                    Button(action: {
                                        questions.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            questions.append("")
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Question")
                            }
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Generate Summary Button
                    Button(action: generateSummary) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Generate Visit Summary")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isGenerating)
                    .padding(.horizontal)
                    
                    // Summary display
                    if let summary = latestSummary {
                        SummaryView(summary: summary)
                        
                        // Export Button
                        Button(action: {
                            showExportOptions = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Summary")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        // Using confirmation dialog (macOS compatible) instead of actionSheet
                        .confirmationDialog("Export Summary", isPresented: $showExportOptions, titleVisibility: .visible) {
                            Button("Share as Text") {
                                shareSummaryAsText()
                            }
                            Button("Print") {
                                printSummary()
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Choose how to share your visit summary")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Doctor Visit Prep")
            .onAppear(perform: loadExistingSummary)
        }
    }
    
    private var latestSummary: DoctorVisitSummary? {
        doctorVisitSummaries.sorted(by: { $0.endDate > $1.endDate }).first
    }
    
    private func getDateRange() -> (Date, Date) {
        let calendar = Calendar.current
        let endDate = Date()
        var startDate: Date
        
        switch selectedDateRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        case .threeMonths:
            startDate = calendar.date(byAdding: .month, value: -3, to: endDate)!
        case .custom:
            return (customStartDate, customEndDate)
        }
        
        return (startDate, endDate)
    }
    
    private func loadExistingSummary() {
        // Check if there are any summaries
        if doctorVisitSummaries.isEmpty {
            // Create a mock summary if none exists
            let _ = MockDataGenerator.createMockDoctorVisitSummary(modelContext: modelContext)
        }
        
        // If there's a saved summary, pre-populate questions
        if let summary = latestSummary, !summary.questions.isEmpty {
            questions = summary.questions
        }
    }
    
    private func generateSummary() {
        isGenerating = true
        
        // Get the date range
        let (startDate, endDate) = getDateRange()
        
        // Get journal entries within the date range
        let entries = journalEntries.filter { entry in
            return entry.date >= startDate && entry.date <= endDate
        }
        
        // Filter out empty questions
        let filteredQuestions = questions.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Generate summary using AIService
        AIService.shared.generateDoctorVisitSummary(from: entries, questions: filteredQuestions, modelContext: modelContext) { summary, error in
            DispatchQueue.main.async {
                self.isGenerating = false
            }
        }
    }
    
    private func shareSummaryAsText() {
        guard let summary = latestSummary else { return }
        
        // Format the summary as text
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        var text = "Health Summary: \(formatter.string(from: summary.startDate)) - \(formatter.string(from: summary.endDate))\n\n"
        
        text += "KEY SYMPTOMS REPORTED:\n"
        for symptom in summary.keySymptoms {
            text += "• \(symptom.name): \(symptom.occurrences) occurrences (avg. severity \(String(format: "%.1f", symptom.averageSeverity))/10)\n"
        }
        
        text += "\nOVERALL PATTERNS:\n"
        for pattern in summary.overallPatterns {
            text += "• \(pattern)\n"
        }
        
        text += "\nQUESTIONS FOR DOCTOR:\n"
        for (index, question) in summary.questions.enumerated() {
            text += "\(index + 1). \(question)\n"
        }
        
        // Share the text using cross-platform sharing
        #if os(iOS)
        // iOS-specific sharing
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
        #else
        // macOS sharing
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        print("Summary text copied to clipboard")
        #endif
    }
    
    private func printSummary() {
        #if os(iOS)
        // iOS printing
        // In a real app, we would use UIPrintInteractionController for printing
        print("Summary would be printed")
        #else
        // macOS printing
        // In a real app, we would use NSPrintInfo and NSPrintOperation for printing
        print("Summary would be printed")
        #endif
    }
}

struct SummaryView: View {
    let summary: DoctorVisitSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Key Symptoms
            VStack(alignment: .leading, spacing: 10) {
                Text("Key Symptoms Reported")
                    .font(.headline)
                
                ForEach(summary.keySymptoms) { symptom in
                    HStack {
                        Text("•")
                        Text("\(symptom.name)")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(symptom.occurrences) occurrences")
                        Text("(avg. \(String(format: "%.1f", symptom.averageSeverity))/10)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
            
            // Overall Patterns
            VStack(alignment: .leading, spacing: 10) {
                Text("Overall Patterns")
                    .font(.headline)
                
                ForEach(summary.overallPatterns, id: \.self) { pattern in
                    HStack(alignment: .top) {
                        Text("•")
                        Text(pattern)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // Questions for Doctor
            VStack(alignment: .leading, spacing: 10) {
                Text("Questions for Doctor")
                    .font(.headline)
                
                ForEach(summary.questions.indices, id: \.self) { index in
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                        Text(summary.questions[index])
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    DoctorVisitPrepView()
        .modelContainer(for: [DoctorVisitSummary.self, SymptomSummary.self, JournalEntry.self], inMemory: true)
}
