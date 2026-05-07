//
//  API_SERVICE_VC.swift
//  Career_Assitant
//
//  Created by Dhairya on 01/05/2026

import UIKit

// MARK: - Config
struct GroqConfig {
    static var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String ?? ""
    }
    static var geminiApiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String ?? ""
    }
    static let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    // Added the specific Gemini endpoint for 2026
    static let geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/\(geminiModel):generateContent"
    static let geminiModel = "gemini-3-flash-preview"
    static let model = "llama-3.3-70b-versatile"
}



