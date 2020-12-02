//
//  MyanmarOCR.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import Foundation
import SwiftyTesseract

protocol MyanmarOcrDelegate: class {
    func myanmarOcrDelegate(_ ocr: MyanmarOCR, didFinishrecognizing textRects: [TextRect])
}

final class MyanmarOCR: NSObject {
    
    
    
    private let tesseract = SwiftyTesseract(languages: [.burmese, .english], dataSource: Bundle.main, engineMode: .lstmOnly)
    
    weak var delegate: MyanmarOcrDelegate?
    
    let queue = DispatchQueue(label: "com.jonahaung.ocrQueue", attributes: .concurrent)
    let semaphore = DispatchSemaphore(value: 1)
    
    deinit {
        
        semaphore.signal()
        print("MyanmarOCR")
    }
    
    func perfom(for textRects: [TextRect]) {
        
        let count = textRects.count
        let isMyanmar = userDefaults.isMyanmar
        for (i, textRect) in textRects.enumerated() {
            guard isMyanmar else {
                textRect.recognizedText = textRect.text
                textRect.display()
                if i == count-1 {
                    
                    self.delegate?.myanmarOcrDelegate(self, didFinishrecognizing: textRects)
                }
                continue
            }
            
            queue.async { [weak self, weak textRect] in
                guard let self = self, let textRect = textRect else { return }
                self.semaphore.wait()
                guard let image = textRect.image else {
                    
                    self.semaphore.signal()
                    return
                }
                self.tesseract.performOCR(on: image) { [weak self]  string in
                    textRect.recognizedText = string?.trimmed
                    DispatchQueue.main.async { [weak textRect] in
                        textRect?.display()
                    }
                    self?.semaphore.signal()
                    if i == count-1 {
                        sleep(5)
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.delegate?.myanmarOcrDelegate(self, didFinishrecognizing: textRects)
                        }
                    }
                }
            }
        }
    
    }
}
