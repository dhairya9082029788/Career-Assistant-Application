//
//  Prompts_VC.swift
//  Career_Assitant
//
//  Created by Dhairya on 01/05/26.
//
import UIKit

// MARK: - API
enum ActionMode: Equatable {
    case tailor, coverLetter, coldEmail, review

    private var validationGuard: String {
        """
        IMPORTANT: First, evaluate the 'JOB DESCRIPTION' text. If it is random gibberish, 
        a list of unrelated items, or clearly NOT a professional job listing, 
        respond ONLY with the exact string: 'ERROR_INVALID_INPUT'. 
        Do not provide any other analysis or greeting.
        
        If the input IS a valid job description, proceed with the following task:
        """
    }

    var systemPrompt: String {
        "You are a top 1% Technical Recruiter. You have zero tolerance for generic AI resumes, buzzwords, and plagiarism. Be brutally honest."
    }

    var userPrompt: String {
        switch self {
        case .review:
            return """
            \(validationGuard)
            ACT AS A BRUTAL ELITE TECHNICAL RECRUITER.
            AUDIT THIS RESUME AGAINST THE JOB DESCRIPTION WITH 100% STRICTNESS.

            CRITERIA:
            1. PLAGIARISM: Flag if the resume copies JD phrasing 1:1.
            2. AI DETECTION: Flag generic AI clichés (e.g., 'In the ever-evolving landscape').
            3. TECHNICAL SKILLS: Penalize if skills aren't backed by STAR-method bullets.
            4. FORMAT/DENSITY: Flag if too dense or too sparse for the experience level.
            5. PROFESSIONAL SUMMARY: Penalize if it's generic 'objective' style, not 'value' style.

            OUTPUT FORMAT (STRICT — DO NOT DEVIATE):
            [SCORE: 0-100]
            [RED_FLAGS: List critical errors, plagiarism, or AI tone found]
            [KEYWORDS: List missing technical and soft skills]
            [REVIEW: Your brutal summary and 3 key actionable changes]
            """
        case .tailor:
            return "\(validationGuard) Tailor this resume to the job description. Remove AI buzzwords. Use high-impact action verbs. Align every bullet point to the JD requirements. Return the full tailored resume."
        case .coverLetter:
            return "\(validationGuard) Write a modern, punchy cover letter. Do NOT start with 'I am writing to...'. Focus on solving the company's problems with concrete examples from the resume. Max 3 paragraphs."
        case .coldEmail:
            return "\(validationGuard) Write a 3-paragraph cold email to a recruiter. High-impact opening, specific value proposition, clear CTA. Subject line included."
        }
    }
}
