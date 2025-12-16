//
//  giftPrompt.swift
//  CameraTesting
//
//  Created by csuftitan on 12/15/25.
//
import Foundation
import SwiftUI

func makePrompt(for favorites:[String]) -> String{
    """
    Given these items that someone likes a lot:
    \(favorites.joined(separator: ", "))
    
    Recommend me 3 thoughtful gift ideas
    """
}

func askGPT(prompt: String) async throws -> String {
    let apiKey = Secrets.gptAPIKey
    
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "model": "gpt-4o-mini",
        "messages":[
            ["role": "user", "content":prompt]
        ]
    ]
    request.httpBody = try JSONSerialization.data(withJSONObject: body)
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let choices = json?["choices"] as? [[String: Any]]
    let message = choices?.first?["message"] as? [String: Any]
    
    return message?["content"] as? String ?? "No Response"
    
}
