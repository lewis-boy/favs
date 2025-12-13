//
//  CameraView.swift
//  CameraTesting
//
//  Created by csuftitan on 12/7/25.
//

import Foundation
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable{
    
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
 
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() //creates Camera picker
        picker.delegate = context.coordinator // set coordinator as delegate
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        //No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView){
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
            if let image = info[.originalImage] as? UIImage {
                parent.image = image // pass the selected image to the parent(our app)
            }
            parent.presentationMode.wrappedValue.dismiss() //dismisses the picker
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() //dismiss on cancel
        }
    }
}
