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
    @StateObject var vm = ContentViewModel()
    
    @State private var name = ""
    @State private var birthdayDate: Date = Date()
    @State private var newFavorite = ""
    @State private var favorites: [String] = []

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
//
//                        TextField("Age", value: $age, format: .number)
//                            .keyboardType(.numberPad)
                        HStack{
                            TextField("Add favorite", text: $newFavorite)
                                .onSubmit(addFavorite)
                            Button("Tap here to add to list", action: addFavorite)
                        }
                        ForEach(favorites, id: \.self){fav in
                            HStack{
                                Text(fav)
                            }
                        }
                        if favorites.isEmpty{
                            Text("Don't forget to ask them for their favorites")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                    
                
                    
                
            }
    }
    
    private func saveBirthday (){
        guard !name.isEmpty else {return}
        vm.addBirthday(name: name, birthday: birthdayDate, favorites: favorites)
        dismiss()
    }
    private func addFavorite() {
        let formattedFavorite = newFavorite.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !formattedFavorite.isEmpty else {return}
        favorites.append(formattedFavorite)
        newFavorite = ""
    }
}

//#Preview{
//    AddBirthdayView()
//}



