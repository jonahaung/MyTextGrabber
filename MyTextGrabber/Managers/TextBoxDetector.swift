//
//  TextBoxDetector.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 27/11/20.
//

import UIKit
import Vision

struct TextBoxDetector {
    
    static func detect(image: UIImage, completion: @escaping ([TextRect])->Void) {
        guard let buffer = image.pixelBuffer() else {
            completion([])
            return
        }
        
        detect(cvBuffer: buffer, completion: completion)
    }
    
    static func detect(cvBuffer: CVPixelBuffer, completion: @escaping ([TextRect])->Void) {
        let request = VNRecognizeTextRequest { (x, _) in
            guard let results = x.results as? [VNRecognizedTextObservation] else { return }
            let textRects = results.map{TextRect(observation: $0)}.compactMap{$0}
    
    
            completion(textRects)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: cvBuffer, orientation: .up)
        
        try? handler.perform([request])
    }
}
