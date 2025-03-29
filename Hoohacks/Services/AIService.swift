//
//  AIService.swift
//  Hoohacks
//
//  Created by Koosha Paridehpour on 3/29/25.
//

import Foundation
import SwiftData

class AIService {
    static let shared = AIService()
    
    private let apiKey = "YOUR_GEMINI_API_KEY" // This would be stored securely in a real app
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    
    // Generate a weekly summary based on journal entries
    func generateWeeklySummary(from entries: [JournalEntry], completion: @escaping (String?, Error?) -> Void) {
        // In a real implementation, this would make an API call to Gemini
        // For the MVP, we'll return mock data
        
        // Format the entries into a prompt for the AI
        let prompt = formatWeeklySummaryPrompt(entries: entries)
        
        // For demo purposes, we'll return a static summary
        // In a real implementation, we would send the prompt to the Gemini API
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // This would be the response from Gemini in a real implementation
            let mockSummary = """
            This week, you logged headaches on 3 days, typically rating them as moderate to severe (6-7/10). 
            Your energy levels tended to be higher on days when you slept more than 7 hours and took more 
            than 8,000 steps. Notably, all headache days occurred when you had fewer than 6 hours of sleep 
            and lower physical activity. Your heart rate was also slightly elevated on these days compared 
            to your headache-free days.
            """
            
            completion(mockSummary, nil)
        }
    }
    
    // Generate pattern analysis for a specific symptom
    func generatePatternAnalysis(symptom: String, entries: [JournalEntry], completion: @escaping ([Pattern]?, Error?) -> Void) {
        // Format the entries into a prompt for the AI
        let prompt = formatPatternAnalysisPrompt(symptom: symptom, entries: entries)
        
        // For demo purposes, we'll return static patterns
        // In a real implementation, we would send the prompt to the Gemini API
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // This would be the response from Gemini in a real implementation
            let mockPatterns = [
                Pattern(
                    symptomName: symptom,
                    description: "You averaged 5.8 hours of sleep on headache days vs. 7.3 hours on headache-free days",
                    correlationStrength: 0.85,
                    relatedFactors: ["Sleep", "Stress"]
                ),
                Pattern(
                    symptomName: symptom,
                    description: "You tagged 'skipped meals' on 100% of headache days vs. 0% of headache-free days",
                    correlationStrength: 0.9,
                    relatedFactors: ["Nutrition", "Meal timing"]
                ),
                Pattern(
                    symptomName: symptom,
                    description: "Your step count averaged 4,000 on headache days vs. 8,500 on headache-free days",
                    correlationStrength: 0.7,
                    relatedFactors: ["Physical activity", "Sedentary behavior"]
                )
            ]
            
            completion(mockPatterns, nil)
        }
    }
    
    // Generate a doctor visit summary
    func generateDoctorVisitSummary(from entries: [JournalEntry], questions: [String], modelContext: ModelContext, completion: @escaping (DoctorVisitSummary?, Error?) -> Void) {
        // Format the entries into a prompt for the AI
        let prompt = formatDoctorVisitSummaryPrompt(entries: entries, questions: questions)
        
        // For demo purposes, we'll return a static summary
        // In a real implementation, we would send the prompt to the Gemini API
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // This would be the response from Gemini in a real implementation
            let mockSummary = MockDataGenerator.createMockDoctorVisitSummary(modelContext: modelContext)
            completion(mockSummary, nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func formatWeeklySummaryPrompt(entries: [JournalEntry]) -> String {
        // Format the entries into a structured prompt for the AI
        var prompt = "Analyze the following health journal entries for the past week:\n\n"
        
        for entry in entries {
            prompt += "Date: \(formattedDate(entry.date))\n"
            prompt += "Mood: \(entry.mood)/5\n"
            prompt += "Energy: \(entry.energy)/5\n"
            
            prompt += "Symptoms: "
            if entry.symptoms.isEmpty {
                prompt += "None\n"
            } else {
                prompt += "\n"
                for symptom in entry.symptoms {
                    prompt += "- \(symptom.name) (Severity: \(symptom.severity)/10)\n"
                }
            }
            
            prompt += "Notes: \(entry.notes)\n"
            prompt += "Tags: \(entry.tags.joined(separator: ", "))\n"
            
            prompt += "Sleep: \(entry.sleepHours ?? 0) hours\n"
            prompt += "Steps: \(entry.stepCount ?? 0)\n"
            prompt += "Active Calories: \(entry.activeCalories ?? 0)\n"
            prompt += "Resting Heart Rate: \(entry.restingHeartRate ?? 0) bpm\n\n"
        }
        
        prompt += "Based on this data, provide a concise summary of patterns observed, potential correlations between symptoms and lifestyle factors, and any notable trends. Focus on information that would be useful for the user to understand their health patterns. Use simple, non-clinical language."
        
        return prompt
    }
    
    private func formatPatternAnalysisPrompt(symptom: String, entries: [JournalEntry]) -> String {
        // Format the entries into a structured prompt for the AI, focusing on a specific symptom
        var prompt = "Analyze the following health journal entries to identify patterns related to '\(symptom)':\n\n"
        
        // Separate entries with and without the symptom
        let symptomEntries = entries.filter { entry in
            entry.symptoms.contains(where: { $0.name.lowercased() == symptom.lowercased() })
        }
        
        let nonSymptomEntries = entries.filter { entry in
            !entry.symptoms.contains(where: { $0.name.lowercased() == symptom.lowercased() })
        }
        
        prompt += "Entries WITH \(symptom):\n"
        for entry in symptomEntries {
            prompt += formatEntryForPrompt(entry)
        }
        
        prompt += "\nEntries WITHOUT \(symptom):\n"
        for entry in nonSymptomEntries {
            prompt += formatEntryForPrompt(entry)
        }
        
        prompt += "\nBased on this data, identify up to 3 potential correlations or patterns related to '\(symptom)'. For each pattern, describe the correlation, estimate its strength, and list related factors. Focus on comparing days with the symptom to days without it."
        
        return prompt
    }
    
    private func formatDoctorVisitSummaryPrompt(entries: [JournalEntry], questions: [String]) -> String {
        // Format the entries into a structured prompt for the AI, designed for doctor visit preparation
        var prompt = "Create a concise summary for a doctor's visit based on the following health journal entries:\n\n"
        
        for entry in entries {
            prompt += formatEntryForPrompt(entry)
        }
        
        prompt += "\nUser's questions for the doctor:\n"
        for (index, question) in questions.enumerated() {
            prompt += "\(index + 1). \(question)\n"
        }
        
        prompt += "\nCreate a structured summary with these sections:\n"
        prompt += "1. Key Symptoms Reported (name, frequency, average severity)\n"
        prompt += "2. Overall Patterns (correlations between symptoms and lifestyle factors)\n"
        prompt += "3. Questions for Doctor (formatted clearly)\n"
        prompt += "\nKeep the summary concise, objective, and focused on information that would be most relevant for a healthcare provider."
        
        return prompt
    }
    
    private func formatEntryForPrompt(_ entry: JournalEntry) -> String {
        var entryText = "Date: \(formattedDate(entry.date))\n"
        entryText += "Mood: \(entry.mood)/5, Energy: \(entry.energy)/5\n"
        
        entryText += "Symptoms: "
        if entry.symptoms.isEmpty {
            entryText += "None\n"
        } else {
            entryText += "\n"
            for symptom in entry.symptoms {
                entryText += "- \(symptom.name) (Severity: \(symptom.severity)/10)\n"
            }
        }
        
        entryText += "Sleep: \(entry.sleepHours ?? 0) hours, "
        entryText += "Steps: \(entry.stepCount ?? 0), "
        entryText += "Heart Rate: \(entry.restingHeartRate ?? 0) bpm\n"
        entryText += "Tags: \(entry.tags.joined(separator: ", "))\n\n"
        
        return entryText
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // This would be the actual Gemini API call in a real implementation
    private func callGeminiAPI(prompt: String, completion: @escaping (String?, Error?) -> Void) {
        // Create the URL
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            completion(nil, NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create the request body
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        // Convert the request body to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(nil, error)
            return
        }
        
        // Make the API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }
            
            // Parse the response
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let candidate = candidates.first,
                   let content = candidate["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let part = parts.first,
                   let text = part["text"] as? String {
                    completion(text, nil)
                } else {
                    completion(nil, NSError(domain: "AIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"]))
                }
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
