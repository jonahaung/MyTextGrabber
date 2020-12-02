//
//  CustomCameraView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI
import UIKit
import VisionKit

struct CustomCameraView: UIViewControllerRepresentable {
    
    @Binding var scannedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    typealias UIViewControllerType = CameraViewController
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(scannedImage: $scannedImage, presentationMode: presentationMode)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomCameraView>) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CustomCameraView>) {
    }
    
    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
    
        private var scannedImage: Binding<UIImage?>
        var presentationMode: Binding<PresentationMode>
        
        init(scannedImage: Binding<UIImage?>, presentationMode: Binding<PresentationMode>) {
            self.presentationMode = presentationMode
            self.scannedImage = scannedImage
        }
        
        func customCameraViewController(_ contoller: CameraViewController, didCaptureImage image: UIImage) {
            scannedImage.wrappedValue = image
            presentationMode.wrappedValue.dismiss()
        }
    }
}

