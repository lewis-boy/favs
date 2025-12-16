//
//  ContentViewModel.swift
//  CameraTesting
//
//  Created by csuftitan on 12/15/25.
//

import CoreData
import SwiftUI
internal import Combine

class ContentViewModel: ObservableObject{
    @Published var savedBirthdays: [SpecialDay] = []
    let container: NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "BirthdayModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Failed to load the data \(error)")
            } else{
                print("Successful connection")
            }
        }
        fetchBirthdays()
    }
    
    func fetchBirthdays(){
        let request = NSFetchRequest<SpecialDay>(entityName: "SpecialDay")
        do{
            savedBirthdays = try container.viewContext.fetch(request)
        }catch let error{
            print("Error while fetching \(error)")
        }
    }
    
    func addBirthday(name: String, birthday: Date, favorites: [String]){
        let newBirthday = SpecialDay(context: container.viewContext)
        newBirthday.name = name
        newBirthday.birthdayDate = birthday
        newBirthday.favoritesArray = favorites
        saveData()
    }
    
    func saveData(){
        do{
            try container.viewContext.save()
            fetchBirthdays()
            print("Successfully saved")
        } catch let error{
            print("Error while saving context \(error)")
        }
    }
    
    func deleteBirthday(indexSet: IndexSet){
        guard let index = indexSet.first else {return}
        let birthdayToDelete = savedBirthdays[index]
        container.viewContext.delete(birthdayToDelete)
        saveData()
    }
}
