//
//  ContentViewManager.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 27/11/20.
//

import UIKit
import VisionKit

class ContentViewManager: NSObject {
    
   
}

extension ContentViewManager: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) {
            guard scan.pageCount > 0 else {
                return
            }
            let image = scan.imageOfPage(at: 0)
            let x = ScannerNavigationController(image)
            x.modalPresentationStyle = .fullScreen
            UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension ContentViewManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let image = info[.originalImage] as? UIImage else { return }
            let x = ScannerNavigationController(image)
            x.modalPresentationStyle = .fullScreen
            UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
        }
    }
}
