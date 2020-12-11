//
//  ImageScannerResult.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 27/11/20.
//

import UIKit
import SwiftUI

class ImageScannerResult: ObservableObject {

    private var originalImage: UIImage = UIImage()
    private var grayScaledImage: UIImage?
    private var blackAndWhiteImage: UIImage?
    @Published var editedImage: UIImage = UIImage()
    @Published var text: String = ""
    @Published var quadrilateral: Quadrilateral?
    @Published var viewSate = ViewState.None
    
    var scannedImage: UIImage? {
        didSet {
            guard let scannedImage = scannedImage else { return }
            let scaledSize = scannedImage.size.scaleSize(for: 700)
                guard scaledSize.width <= 700 || scaledSize.height <= 700 else {
                    setImage(image: scannedImage)
                    return
                }
            guard
                let _pixelBuffer = scannedImage.pixelBuffer(width: scaledSize.width.int, height: scaledSize.height.int),
                let resizedImage = UIImage(pixelBuffer: _pixelBuffer) else {
                return
            }
            
            setImage(image: resizedImage)
            CurrentSession.videoSize = resizedImage.size
        }
    }
    init(text: String) {
       
        self.text = text
    }
    
    init(){
        
    }
    
    
    private func setImage(image: UIImage) {
        originalImage = image
        editedImage = image
        if let buffer = originalImage.pixelBufferGray(width: originalImage.size.width.int, height: originalImage.size.height.int), let image = UIImage(pixelBuffer: buffer) {
            grayScaledImage = image
        }
        guard let ci = CIImage(image: originalImage) else { return }
        let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(originalImage.imageOrientation).rawValue))
        if let image = ciImage.appalyingNoiseReduce()?.applyingAdaptiveThreshold()?.uiImage {
            blackAndWhiteImage = image
        }
    }
    
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
