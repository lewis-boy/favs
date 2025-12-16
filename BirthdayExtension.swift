//
//  BirthdayExtension.swift
//  CameraTesting
//
//  Created by csuftitan on 12/15/25.
//
import Foundation
import CoreData

extension SpecialDay {
    var favoritesArray: [String]{
        get {
            favorites as? [String] ?? []
        }set{
            favorites = newValue as NSObject
        }
    }
}
