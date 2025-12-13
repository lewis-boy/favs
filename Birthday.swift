//
//  Birthday.swift
//  CameraTesting
//
//  Created by csuftitan on 12/12/25.
//

import SwiftData
import Foundation

@Model
class Birthday: Identifiable{
    var name: String
    var birthdayDate: Date
    var age: Int
    
    init(name:String, birthdayDate: Date, age: Int){
        self.name = name
        self.birthdayDate = birthdayDate
        self.age = age
    }
}
