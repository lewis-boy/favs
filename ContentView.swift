//
//  ContentView.swift
//  CameraTesting
//
//  Created by csuftitan on 12/7/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import CoreData

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
   
    
    @State private var giftRecommendation: String?
    @State private var apiResult: String?
    @State private var isLoading = false
    @State private var newFavorite = ""
    @State private var selectedFilter: Filters = .none
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingAddBirthday = false
    @State private var result: String = "Press the button to test API"
    @State private var expandedBirthdayID: NSManagedObjectID?
    
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
                
                // subtle “glow blobs” behind glass
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 280, height: 280)
                    .blur(radius: 25)
                    .offset(x: -140, y: -260)

                Circle()
                    .fill(.white.opacity(0.14))
                    .frame(width: 340, height: 340)
                    .blur(radius: 30)
                    .offset(x: 150, y: 260)
                
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
                    
                    // Segmented control “glass bar”
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(Filters.allCases) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(10)
                    .glassRow(radius: 18)
                    .padding(.horizontal, 14)
                    
                    
                    
                    // Birthdays list in a glass card
                    List {
                        ForEach(vm.savedBirthdays) { birthday in
                            let daysLeft = daysUntilBirthday(birthday.birthdayDate!)

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    FavoriteIcon(
                                        color: birthday.favoritesArray.isEmpty ? .yellow : .teal,
                                        systemName: birthday.favoritesArray.isEmpty ? "star.fill" : "music.note"
                                    )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(birthday.name ?? "Stranger")
                                            .font(.custom("Helvetica-Bold", fixedSize: 24))

                                        Text(birthday.birthdayDate?.formatted(.dateTime.month().day()) ?? "")
                                            .font(.custom("DINAlternate-Bold", fixedSize: 20))
                                    }

                                    Spacer()

                                    Text(daysLeft == 0 ? "Today!!" : daysLeft < 0 ? "Celebrated!" : "in \(daysLeft) days")
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        expandedBirthdayID = expandedBirthdayID == birthday.objectID ? nil : birthday.objectID
                                    }
                                }

                                if expandedBirthdayID == birthday.objectID {
                                    Divider().opacity(0.2)

                                    if birthday.favoritesArray.isEmpty {
                                        Text("Pss. You should ask them about their favorites.")
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text(birthday.favoritesArray.joined(separator: ", "))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Button("Ask GPT for gift ideas") {
                                            Task {
                                                isLoading = true
                                                giftRecommendation = nil

                                                let prompt = makePrompt(for: birthday.favoritesArray)

                                                do { giftRecommendation = try await askGPT(prompt: prompt) }
                                                catch { giftRecommendation = "Failed to get recommendation" }

                                                isLoading = false
                                            }
                                        }

                                        if isLoading { ProgressView() }

                                        if let giftRecommendation {
                                            Text(giftRecommendation)
                                                .font(.subheadline)
                                        }
                                    }

                                    HStack {
                                        TextField("Add another favorite", text: $newFavorite)
                                            .textFieldStyle(.plain)
                                            .padding(10)
                                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(.white.opacity(0.18), lineWidth: 1)
                                            )

                                        Button("Add") {
                                            let formattedInput = newFavorite.trimmingCharacters(in: .whitespacesAndNewlines)
                                            guard !formattedInput.isEmpty else { return }

                                            birthday.favoritesArray.append(formattedInput)
                                            newFavorite = ""
                                            try? vm.saveData()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(.white.opacity(0.18), lineWidth: 1)
                                        )
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(14)
                            .glassRow(radius: 22)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: vm.deleteBirthday)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .glassCard(radius: 28)
                    .padding(.horizontal, 14)
                    
                    if let apiResult = apiResult {
                        Text("This is what Google thinks of your image: \(apiResult)")
                    }
                    
                    if let selectedImage = selectedImage {
                        ZStack(alignment: .topTrailing){
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(25)
                                .overlay(
                                    Button(action: {
                                        self.selectedImage = nil
                                    }){
                                        Text("close")
                                    }
                                )
                        }
                        
                        
                    }
                    else{
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
                                    Button("Test Vision API"){
                                        Task{
                                            if let image = selectedImage,
                                               let base64 = image.toBase64(){
                    
                                                do{
                                                    let identifier  = try await VisionService().detectObject(base64: base64)
                                                    result = "API result: \(identifier)"
                                                    apiResult = result
                                                    print("API result:", identifier)
                                                    self.selectedImage = nil
                                                }catch{
                                                    result = "Error: \(error)"
                                                    print(error)
                                                    self.selectedImage = nil
                                                }
                                            }
                                            else{
                                                result = "Failed to load Base64"
                                                self.selectedImage = nil
                                            }
                                        }
                                        
                                    }
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

private func daysUntilBirthday(_ birthdayDate: Date) -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    
    var components = calendar.dateComponents([.month, .day], from: birthdayDate)
    components.year = calendar.component(.year, from: today)
    
    guard let nextBirthday = calendar.date(from: components) else{
        return -1
    }
    
    if nextBirthday < today {return -1}
    if nextBirthday == today {return 0}
    
    return calendar.dateComponents([.day], from: today, to: nextBirthday).day ?? -1
}

extension UIImage {
    func toBase64() -> String? {
        guard let jpegData = self.jpegData(compressionQuality: 0.8) else{
            return nil
        }
        return jpegData.base64EncodedString()
    }
}

private extension View {
    func glassCard(radius: CGFloat = 26) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(radius: 18)
    }

    func glassRow(radius: CGFloat = 20) -> some View {
        self
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            )
    }
}

private struct GlassPillButtonStyle: ButtonStyle {
    var tint: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(tint)
                        .opacity(configuration.isPressed ? 0.35 : 0.22)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(.white.opacity(configuration.isPressed ? 0.14 : 0.22), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(radius: configuration.isPressed ? 6 : 10)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

private extension ButtonStyle where Self == GlassPillButtonStyle {
    static func glassPill(tint: Color = .white.opacity(0.18)) -> GlassPillButtonStyle {
        GlassPillButtonStyle(tint: tint)
    }
}

#Preview {
    ContentView()
}
