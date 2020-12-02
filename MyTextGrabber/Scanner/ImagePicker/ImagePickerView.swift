//
//  ImagePickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI
import UIKit
import VisionKit

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var scannedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(scannedImage: $scannedImage, presentationMode: presentationMode)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
        let imagePickerViewController = UIImagePickerController()
        
        imagePickerViewController.sourceType = .photoLibrary
        imagePickerViewController.allowsEditing = false
        imagePickerViewController.delegate = context.coordinator
        return imagePickerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        private var scannedImage: Binding<UIImage?>
        var presentationMode: Binding<PresentationMode>
        
        init(scannedImage: Binding<UIImage?>, presentationMode: Binding<PresentationMode>) {
            self.presentationMode = presentationMode
            self.scannedImage = scannedImage
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            scannedImage.wrappedValue = info[.originalImage] as? UIImage
            presentationMode.wrappedValue.dismiss()
        }
    }
}

