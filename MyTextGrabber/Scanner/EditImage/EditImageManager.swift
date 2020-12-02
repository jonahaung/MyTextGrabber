//
//  EditImageManager.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 30/11/20.
//

import UIKit
import Vision

protocol EditImageManagerDelegate: class {
    var result: ImageScannerResult { get }
    func editImageManager(didFinishEditingImage manager: EditImageManager)
    func editImageManager(_ manager: EditImageManager, didFinishDetecting textRects: [TextRect])
    func editImageManager(_ manager: EditImageManager, showLoading isLoading: Bool)
    func editImageManager(_ manager: EditImageManager, didFinishDisplayingLines textRects: [TextRect])
}

final class EditImageManager: NSObject {
    
    weak var delegate: EditImageManagerDelegate?
    private var result: ImageScannerResult? { return delegate?.result }
    var currentTextRects = [TextRect]()
    
    override init() {
        super.init()
        
    }
    
    func cropToFit() {
        
        guard !currentTextRects.isEmpty, let result = result else { return }
        let boundingBox = currentTextRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
        let imageRect = VNImageRectForNormalizedRect(boundingBox.normalized(), result.editedImage.size.width.int, result.editedImage.size.height.int)
        guard
            let pixelBuffer = result.editedImage.pixelBuffer(),
            let cgImage = CGImage.create(pixelBuffer: pixelBuffer),
            let cropped = cgImage.cropping(to: imageRect)
        else {
            print("no pixel buffer")
            return
        }
        
        let uiImage = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        result.editedImage = uiImage
        delegate?.editImageManager(didFinishEditingImage: self)
    }
    func cropToQuad(for quadView: QuadrilateralView) {
       
        guard let quad = quadView.quad, let result = result, let ciImage = CIImage(image: result.editedImage) else {
            return
        }
        let cgOrientation = CGImagePropertyOrientation(result.editedImage.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, result.editedImage.size)
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: result.editedImage.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])

        result.editedImage = filteredImage.uiImage ?? UIImage()
        delegate?.editImageManager(didFinishEditingImage: self)
    }
    
    deinit {
        
        currentTextRects.removeAll()
        print("EditImageManager")
    }
    func getAllTexts() {
        
    }
    
    func showLoading(isLoading: Bool) {
        delegate?.editImageManager(self, showLoading: isLoading)
    }
}

extension EditImageManager: MyanmarOcrDelegate {
    
    func myanmarOcrDelegate(_ ocr: MyanmarOCR, didFinishrecognizing textRects: [TextRect]) {
        delegate?.editImageManager(self, didFinishDisplayingLines: textRects)
    }
    
    
}

extension EditImageManager {
    
    func detectTextBoxes() {
        showLoading(isLoading: true)
        guard let pixelBuffer = self.result?.editedImage.pixelBuffer() else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        let textRequest = VNRecognizeTextRequest(completionHandler: textCompletionHandler(request:error:))
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([textRequest])
        }
    }
    
    private func textCompletionHandler(request: VNRequest?, error:Error?) {
        guard let results = request?.results as? [VNRecognizedTextObservation] else { return }
        let textRects = results.map{TextRect(observation: $0)}.compactMap{$0}
        guard !textRects.isEmpty else { return }
        DispatchQueue.main.async {
            self.showLoading(isLoading: false)
            self.delegate?.editImageManager(self, didFinishDetecting: textRects)
            self.currentTextRects = textRects
        }
    }
    
    
    @objc func displayLines(_ sender: UIBarButtonItem?) {
        guard !currentTextRects.isEmpty, let image = result?.editedImage else {
            return
        }
        guard let ci = CIImage(image: image) else { return }
        let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(image.imageOrientation).rawValue))
        
        currentTextRects.forEach {
            $0.cropImage(ciImage: ciImage)
        }
        
        let myanmarOCR = MyanmarOCR()
        
        myanmarOCR.delegate = self
        
        myanmarOCR.perfom(for: currentTextRects)
    }
    
}


extension EditImageManager {
    
    @objc func applyFilter(_ sender: UIBarButtonItem?) {
        guard let image = result?.editedImage else { return }
        showLoading(isLoading: true)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let ci = CIImage(image: image) else { return }
            let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(image.imageOrientation).rawValue))
            let uiImage = ciImage.appalyingNoiseReduce()?.applyingAdaptiveThreshold()?.uiImage ?? UIImage()
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showLoading(isLoading: false)
                self.result?.editedImage = uiImage
                self.delegate?.editImageManager(didFinishEditingImage: self)
            }
        }
    }
}

extension EditImageManager {
    
    @objc func reset() {
        guard let result = result else { return }
        currentTextRects.forEach{$0.remove()}
        currentTextRects.removeAll()
        result.editedImage = result.originalImage
        self.delegate?.editImageManager(didFinishEditingImage: self)
    }
    func cleanUpScreen() {
        currentTextRects.forEach{$0.remove()}
    }
    
    func getQuad(for size: CGSize) -> Quadrilateral {
        if currentTextRects.isEmpty {
            return Quadrilateral(rect: CGRect(origin: .zero, size: size).insetBy(dx: size.width/4, dy: size.height/3))
            
        }
        guard let result = result else {
            fatalError()
        }
        let imageSize = result.editedImage.size
        let normalizedRect = currentTextRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
        
       let imageRect = VNImageRectForNormalizedRect(normalizedRect.normalized(), imageSize.width.int, imageSize.height.int)
        
        
        
        let scale = size.width / imageSize.width
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        let viewRect = imageRect.applying(scaledTransform)
        print(viewRect)
        return Quadrilateral(rect: viewRect)
    }
}
