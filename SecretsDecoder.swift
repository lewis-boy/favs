//
//  SecretsDecoder.swift
//  CameraTesting
//
//  Created by csuftitan on 12/13/25.
//


import Foundation

enum Secrets{
    static var visionAPIKey: String{
        print(Bundle.main.infoDictionary ?? [:])
        guard let vKey = Bundle.main.infoDictionary?["VISION_API_KEY"] as? String else {
            fatalError("Vision API Key not found, check your Secrets.xconfig")
        }
        return vKey
    }
    static var gptAPIKey: String{
        guard let gKey = Bundle.main.infoDictionary?["GPT_KEY"] as? String else {
            fatalError("GPT API Key not found, check your Secrets.xconfig")
        }
        return gKey
    }
}

