//
//  SecretsDecoder.swift
//  CameraTesting
//
//  Created by csuftitan on 12/13/25.
//


import Foundation

enum Secrets{
    static var visionAPIKey: String{
        guard let key = Bundle.main.infoDictionary?["VisionAPIKey"] as? String else {
            fatalError("Vision API Key not found, check your Secrets.xconfig")
        }
        return key
    }
}

