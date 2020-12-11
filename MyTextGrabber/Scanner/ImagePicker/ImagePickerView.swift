//
//  ImagePickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var result: ImageScannerResult
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scannedImage: $result.scannedImage, viewState: $result.viewSate)
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
        private var viewState: Binding<ViewState>
        
        init(scannedImage: Binding<UIImage?>, viewState: Binding<ViewState>) {
            self.scannedImage = scannedImage
            self.viewState = viewState
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            viewState.wrappedValue = .None
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            scannedImage.wrappedValue = (info[.originalImage] as? UIImage)?.withFixedOrientation()
            
            picker.dismiss(animated: true) {
                self.viewState.wrappedValue = .ImageEditorView
            }
        }
    }
}

