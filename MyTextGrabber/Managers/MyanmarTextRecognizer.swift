//
//  MyanmarTextRecognizer.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 18/11/20.
//

import UIKit
import SwiftyTesseract
import Vision

final class MyanmarTextRecognizer {
    
    static let shared = MyanmarTextRecognizer()
    
    private let tesseract = SwiftyTesseract(languages: [.burmese, .english], dataSource: Bundle.main, engineMode: .lstmOnly)
    
    init() {
        tesseract.preserveInterwordSpaces = false
    }
    
    func recognize(image: UIImage,  completion: @escaping (String?)->()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let _ = self.tesseract.performOCR(on: image)
            let wordBlocks = try! self.tesseract.recognizedBlocks(for: .word).get()
            let words = wordBlocks.map{$0.text}.joined(separator: " ")
            DispatchQueue.main.async {
                completion(words)
            }
        }
    }
}
