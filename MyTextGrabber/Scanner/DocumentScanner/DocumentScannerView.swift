//  Created by Martin Mitrevski on 15.06.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import SwiftUI
import UIKit
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(scannedImage: $scannedImage, presentationMode: presentationMode)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentScannerView>) -> VNDocumentCameraViewController {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<DocumentScannerView>) {
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        private var scannedImage: Binding<UIImage?>
        var presentationMode: Binding<PresentationMode>
        
        init(scannedImage: Binding<UIImage?>, presentationMode: Binding<PresentationMode>) {
            self.presentationMode = presentationMode
            self.scannedImage = scannedImage
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                return
            }
            let uiImage = scan.imageOfPage(at: 0)
            self.scannedImage.wrappedValue = uiImage
            presentationMode.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
