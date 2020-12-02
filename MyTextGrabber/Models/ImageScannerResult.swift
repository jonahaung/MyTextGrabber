//
//  ImageScannerResult.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 27/11/20.
//

import UIKit
import Vision

class ImageScannerResult: ObservableObject, Identifiable {

    @Published var originalImage: UIImage = UIImage() {
        didSet {
            if let buffer = originalImage.pixelBufferGray(width: originalImage.size.width.int, height: originalImage.size.height.int), let image = UIImage(pixelBuffer: buffer) {
                grayScaledImage = image
            }
            
            guard let ci = CIImage(image: originalImage) else { return }
            let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(originalImage.imageOrientation).rawValue))
            if let image = ciImage.appalyingNoiseReduce()?.applyingAdaptiveThreshold()?.uiImage {
                blackAndWhiteImage = image
            }
        }
    }
    @Published var editedImage: UIImage = UIImage() {
        didSet {
            CurrentSession.videoSize = editedImage.size
        }
    }
    
    @Published var isEditing = false
    
    var scannedImage: UIImage? {
        didSet {
            let scaledSize = scannedImage?.size.scaleSize(for: UIScreen.main.bounds.height.rounded()) ?? .zero
            guard
                let scannedImage = scannedImage,
                let _pixelBuffer = scannedImage.pixelBuffer(width: scaledSize.width.int, height: scaledSize.height.int),
                let resizedImage = UIImage(pixelBuffer: _pixelBuffer) else {
                isEditing = false
                return
            }
            
            originalImage = resizedImage
            editedImage = resizedImage
            isEditing = true
        }
    }
    
    private var grayScaledImage: UIImage?
    private var blackAndWhiteImage: UIImage?
    
    func thumbnilImage(for filterMode: ImageFilterMode) -> UIImage {
        switch filterMode {
        case .original:
            return originalImage
        case .grayScaled:
            return grayScaledImage ?? editedImage
        case .blackAndWhite:
            return blackAndWhiteImage ?? editedImage
        }
    }


}
