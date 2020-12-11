//
//  ImageFilterMode.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 4/12/20.
//

import Foundation
enum ImageFilterMode: CaseIterable {
    
    case original, grayScaled, blackAndWhite
    
    var description: String {
        switch self {
        case .original:
            return "Original"
        case .grayScaled:
            return "Gray"
        case .blackAndWhite:
            return "Black"
        }
    }
}
