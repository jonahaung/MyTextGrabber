//
//  MyanmarTextRecognizer.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 18/11/20.
//

import UIKit
import SwiftyTesseract

final class MyanmarTextRecognizer {
    
    static let shared = MyanmarTextRecognizer()
    
    private let tesseract = SwiftyTesseract(language: .burmese, dataSource: Bundle.main, engineMode: .lstmOnly)
    
    func recognize(image: UIImage,  completion: @escaping (String?)->()) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let _ = self.tesseract.performOCR(on: image)
            let wordBlocks = try! self.tesseract.recognizedBlocks(for: .word).get()
            let words = wordBlocks.map{ $0.text }
            let joined = words.joined()
            let lines = joined.components(separatedBy: "#")
            let x = lines.map{WordSegmentationManager.shared.tag($0).map{$0.tag}.joined(separator: " ")}.joined(separator: "။")
            DispatchQueue.main.async {
                completion(x)
            }
        }
    }
}
