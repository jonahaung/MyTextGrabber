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
            DispatchQueue.main.async {
                completion([])
            }
            
            return
        }
        
        let request = VNRecognizeTextRequest { (x, _) in
            guard let results = x.results as? [VNRecognizedTextObservation] else { return }
            let textRects = results.map{TextRect(observation: $0)}.compactMap{$0}
    
            DispatchQueue.main.async {
                completion(textRects)
            }
            
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
        
    }
    
    static func detect(cvBuffer: CVPixelBuffer, completion: @escaping ([TextRect])->Void) {
        
    }
}
