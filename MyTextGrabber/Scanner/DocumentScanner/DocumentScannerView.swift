//  Created by Martin Mitrevski on 15.06.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    
    @Binding var result: ImageScannerResult

    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scannedImage: $result.scannedImage, viewState: $result.viewSate)
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
       
        private var viewState: Binding<ViewState>
        
        init(scannedImage: Binding<UIImage?>, viewState: Binding<ViewState>) {
           
            self.scannedImage = scannedImage
            self.viewState = viewState
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                return
            }
            let uiImage = scan.imageOfPage(at: 0).withFixedOrientation()
            
            scannedImage.wrappedValue = uiImage
            controller.dismiss(animated: true) {
                self.viewState.wrappedValue = .ImageEditorView
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            viewState.wrappedValue = .None
            controller.dismiss(animated: true)
        }
    }
}
