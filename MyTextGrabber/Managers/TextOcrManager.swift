//
//  TextOcrManager.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 3/12/20.
//

import UIKit
import Vision
import SwiftyTesseract
import Combine
import SwiftUI
class TextOcrManager: ObservableObject {
    
    @Published var textRects = [TextRect]()
    @Published var progress: CGFloat = 0
    @Published var totalProgress: CGFloat = 0
    @Published var textsAreReady = false
    @Published var isProcessingText = false
    var presentationMode: Binding<PresentationMode>?
    
    var textResult: TextResult = TextResult(text: String(), fontSize: 17)
    
    deinit {
        
        print("TextOcrManager")
    }
    func detectTextBoxes(for image: UIImage) {
        isProcessingText = true
        guard let pixelBuffer = image.pixelBuffer() else { return }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        
        try? handler.perform([textRequest])
        
        guard let results = textRequest.results as? [VNRecognizedTextObservation] else { return }
        let textRects = results.map{TextRect(observation: $0)}.compactMap{$0}
        self.textRects = textRects
        self.displayLines(for: image)
    }
    
    func displayLines(for image: UIImage) {
        guard !textRects.isEmpty else {
            return
        }
        let count = textRects.count
        let languateMode = UserDefaultsManager.shared.languageMode
        
        guard let ci = CIImage(image: image) else { return }
        let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(image.imageOrientation).rawValue))
        totalProgress = CGFloat(textRects.count)
        let queue = DispatchQueue(label: "com.jonahaung.ocrQueue", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)
        let tesseract = SwiftyTesseract(languages: languateMode.recognitionLanguage, dataSource: Bundle.main, engineMode: .lstmOnly)
        
        for (i, textRect) in textRects.enumerated() {
            
            
            queue.async { [weak self, weak textRect] in
                
                guard let self = self, let textRect = textRect else { return }
                
                semaphore.wait()
                textRect.cropImage(ciImage: ciImage)
                guard let image = textRect.image else {
                    semaphore.signal()
                    return
                }
                
                
                let cancellable = tesseract.performOCRPublisher(on: image).sink { complete in
                    switch complete {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        DispatchQueue.main.async { [weak textRect, weak self] in
                            
                            self?.progress += 1
                            textRect?.display()
                            if i == count-1 {
                                self?.getTextResult()
                            }
                        }
                    }
                    semaphore.signal()
                } receiveValue: { text in
                    textRect.recognizedText = text.trimmed
                }
                
                cancellable.cancel()
            }
        }
    }
    
    //     func displayLines(for image: UIImage) {
    //        guard !textRects.isEmpty else {
    //            return
    //        }
    //        let count = textRects.count
    //        let isMyanmar = userDefaults.isMyanmar
    //
    //        guard let ci = CIImage(image: image) else { return }
    //        let ciImage = ci.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(image.imageOrientation).rawValue))
    //        totalProgress = CGFloat(textRects.count)
    //
    //        for (i, textRect) in textRects.enumerated() {
    //            guard isMyanmar else {
    //                textRect.cropImage(ciImage: ciImage)
    //                textRect.recognizedText = textRect.text
    //                textRect.display()
    //                if i == count-1 {
    //                    isProcessingText = false
    //                }
    //                continue
    //            }
    //
    //            queue.async { [weak self, weak textRect] in
    //
    //                guard let self = self, let textRect = textRect else { return }
    //                self.semaphore.wait()
    //                textRect.cropImage(ciImage: ciImage)
    //                guard let image = textRect.image else {
    //                    self.semaphore.signal()
    //                    return
    //                }
    //                let tesseract = SwiftyTesseract(languages: [.burmese, .english], dataSource: Bundle.main, engineMode: .lstmOnly)
    //                let result: Result<String, Error> = tesseract.performOCR(on: image)
    //                let string = try? result.get()
    //                textRect.recognizedText = string?.trimmed
    //                DispatchQueue.main.async { [weak textRect, weak self] in
    //                    textRect?.display()
    //                    self?.progress += 1
    //                }
    //                self.semaphore.signal()
    //                if i == count-1 {
    //                    DispatchQueue.main.async { [weak self] in
    //                        self?.getTextResult()
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func getTextResult() {
        guard !textRects.isEmpty else { return }
        let text = textRects.map{$0.recognizedText}.compactMap{$0}.joined(separator: "\n")
        let fontSize = textRects.map{$0.textLayer.fontSize}.reduce(0, {$0 + Int($1)}) / textRects.count
        
        textResult = TextResult(text: text, fontSize: CGFloat(fontSize))
        progress = 0.0
        totalProgress = 0.0
        textsAreReady = true
        isProcessingText = false
        presentationMode?.wrappedValue.dismiss()

    }
    
    
}
