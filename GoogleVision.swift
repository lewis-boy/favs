//
//  GoogleVision.swift
//  CameraTesting
//
//  Created by csuftitan on 12/7/25.
//
import Foundation

struct VisionResponse: Codable {
    struct Detection: Codable {
        let webDetection: WebDetection?
    }
    struct WebDetection: Codable {
        let bestGuessLabels: [BestGuessLabel]?
        let webEntities: [WebEntity]?
    }
    struct BestGuessLabel: Codable {
        let label: String?
    }
    struct WebEntity: Codable {
        let description: String?
        let score: Double?
    }
    
    let responses: [Detection]
}

class VisionService {
    
    let apiKey = Secrets.visionAPIKey
    
    func detectObject(base64: String) async throws -> String {
        
        let urlString = "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let body: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64],
                    "features": [["type": "WEB_DETECTION"], ["type": "LABEL_DETECTION", "maxResults": 20]]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = jsonData
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: req)
        
        let decoded = try JSONDecoder().decode(VisionResponse.self, from: data)
        
        if let rawJson = String(data: data, encoding: .utf8){
            print("Raw JSON Response:\n\(rawJson)")
        }else{
            print("Failed to decode JSON as UTF-8")
        }
        
    
        if let label = decoded.responses.first?.webDetection?.bestGuessLabels?.first?.label {
            return label.lowercased()
        }
        
        if let entity = decoded.responses.first?.webDetection?.webEntities?.first?.description {
            return entity.lowercased()
        }
        
        return "unknown item"
    }
}

