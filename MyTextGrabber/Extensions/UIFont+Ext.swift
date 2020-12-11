//
//  UIFont+Ext.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 4/12/20.
//

import UIKit

extension UIFont {
    
    static let myanmarFont = UIFont(name:"MyanmarSansPro", size: 35)!
    static let engFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 35, weight: .medium))
    static let myanmarFontBold = UIFontMetrics.default.scaledFont(for: UIFont(name: "MyanmarPhetsot", size: 35)!)
    
    static var monoSpacedFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitMonoSpace)
        fontDescriptor?.withDesign(.monospaced)
        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 22)
        } else {
            font = UIFont.monospacedSystemFont(ofSize: 22, weight: .medium)
        }

        return font
    }
    
}
