//
//  LanguageMode.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 11/12/20.
//

import Foundation
import SwiftyTesseract

enum LanguageMode: Int {
    
    case Myanmar, English, Mixed
    
    var description: String {
        switch self {
        case .Myanmar:
            return "Mya"
        case .English:
            return "Eng"
        case .Mixed:
            return "Mix"
        }
    }
    
    var recognitionLanguage: [RecognitionLanguage] {
        switch self {
        case .Myanmar:
            return [.burmese]
        case .English:
            return [.english]
        case .Mixed:
            return [.burmese, .english]
        }
    }
    
    var toggle: LanguageMode {
        switch self {
        case .Myanmar:
            return .English
        case .English:
            return .Mixed
        case .Mixed:
            return .Myanmar
        }
    }
}
