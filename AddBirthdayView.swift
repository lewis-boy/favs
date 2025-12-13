//
//  AddBirthdayView.swift
//  CameraTesting
//
//  Created by csuftitan on 12/9/25.
//

import SwiftUI
import SwiftData

let backgroundGradient = LinearGradient(
    colors: [Color(red: 1.0, green: 0.87, blue: 0.92), Color.blue],
    startPoint: .top,
    endPoint: .bottom
)

struct AddBirthdayView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var birthdayDate: Date = Date()
    @State private var age = 0

    var body: some View {
            ZStack {
                // BACKGROUND LAYER
                backgroundGradient
                    .ignoresSafeArea()
                
                // FOREGROUND LAYER
                VStack {
                    Button("Save") {
                        saveBirthday()
                    }
                    Form {
                        TextField("Name", text: $name)
                        
                        DatePicker("Birthday", selection: $birthdayDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(.pink)
                        
                        TextField("Age", value: $age, format: .number)
                            .keyboardType(.numberPad)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                    
                
                    
                
            }
    }
    
    private func saveBirthday (){
        guard !name.isEmpty else {
            print("Name field is empty")
            return
        }
        
        let newBirthday = Birthday(
            name: name,
            birthdayDate: birthdayDate,
            age: age
        )
        
        modelContext.insert(newBirthday)
        do{
            try modelContext.save()
            print("Birthday Saved successfully")
        }catch{
            print("Failed to save: \(error.localizedDescription)")
        }
        dismiss()
    }
}

//#Preview{
//    AddBirthdayView()
//}



