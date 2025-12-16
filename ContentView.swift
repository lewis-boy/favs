//
//  ContentView.swift
//  CameraTesting
//
//  Created by csuftitan on 12/7/25.
//

import SwiftUI
import SwiftData
import PhotosUI

let homeGradient = LinearGradient(
    colors: [Color(red: 1.0, green: 0.87, blue: 0.92), Color.blue],
    startPoint: .top,
    endPoint: .bottom
)

enum Filters: String, CaseIterable, Identifiable {
    case none = "None"
    case week = "Week"
    case month = "Month"
    
    var id: String{self.rawValue}
}


struct ContentView: View {
    @StateObject var vm = ContentViewModel()
    
    @State private var selectedFilter: Filters = .none
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingAddBirthday = false
    @State private var result: String = "Press the button to test API"
    
//    func loadBase64() -> String? {
//        guard let url = Bundle.main.url(forResource: "pokemon-guess", withExtension: "txt"),
//            let content = try? String(contentsOf: url)
//        else{
//                print("Failed to load base64 file")
//                return nil
//        }
//        return content
//    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                homeGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack{
                        Text("Favorites")
                            .font(.system(size:48, weight: .bold))
                        Spacer()
                        Button(action: {
                            showingAddBirthday = true
                        }){
                            ZStack{
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "plus")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .sheet(isPresented: $showingAddBirthday, onDismiss: {vm.fetchBirthdays()}){
                            AddBirthdayView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Picker("Picker Name", selection: $selectedFilter){
                        ForEach(Filters.allCases){choice in
                            Text(choice.rawValue).tag(choice)}
                    }
                    .pickerStyle(.segmented)
                    
                    //add birthday list here
                    List{
                        ForEach(vm.savedBirthdays){birthday in
                            HStack(){
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                VStack(alignment: .leading){
                                        Text(birthday.name ?? "Stranger")
                                            .font(.custom("SignPainter-HouseScript", fixedSize: 32))
                                        Text(birthday.birthdayDate?.formatted(.dateTime.month().day()) ?? "R")
                                            .font(.custom("DINAlternate-Bold",fixedSize: 20))
                                        
                                }
                                Spacer()
                                Text(birthday.favoritesArray.isEmpty ? "No favorites yet" : "A list lies here")
                                Text("15 Days")
                                    .font(.custom("DINAlternate-Bold",fixedSize: 20))
                                
                                
                            }
                            
                        }
                        .onDelete(perform: vm.deleteBirthday)
                    }
                    .listStyle(PlainListStyle())
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(25)
                    }else{
                        Text("No image selected")
                            .foregroundStyle(.gray)
                            .padding()
                    }
                    Button(action: {
                        showingCamera = true
                    }){
                        Text("take photo")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.yellow))
                            .foregroundStyle(.black)
                            .cornerRadius(25)
                    }
                    .sheet(isPresented: $showingCamera){
                        CameraView(image: $selectedImage)
                    }
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()){
                        Text("Select Photo")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.purple))
                            .foregroundStyle(.white)
                            .cornerRadius(25)
                    }
                    .onChange(of: selectedItem){
                        newItem in if let newItem = newItem {
                            Task{
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data){
                                    selectedImage = image
                                }
                            }
                        }
                    }
                    //                Button("Test Vision API"){
                    //                    Task{
                    //                        if let image = selectedImage,
                    //                           let base64 = image.toBase64(){
                    //
                    //                            do{
                    //                                let identifier  = try await VisionService().detectObject(base64: base64)
                    //                                result = "API result: \(identifier)"
                    //                                print("API result:", identifier)
                    //                            }catch{
                    //                                result = "Error: \(error)"
                    //                                print(error)
                    //                            }
                    //                        }
                    //                        else{
                    //                            result = "Failed to load Base64"
                    //                        }
                    //                    }
                    //                }
                    //                Button("Test Firebase"){
                    //                    Task{
                    //                        do{
                    //                            try await APITesting().testHelloworld()
                    //                        }catch{
                    //                            print(error)
                    //                        }
                    //                    }
                    //                }
                }
                .padding()
            }
        }
        
    }
}

//extension UIImage {
//    func toBase64() -> String? {
//        guard let jpegData = self.jpegData(compressionQuality: 0.8) else{
//            return nil
//        }
//        return jpegData.base64EncodedString()
//    }
//}

#Preview {
    ContentView()
}
