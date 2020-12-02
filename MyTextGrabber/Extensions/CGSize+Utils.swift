//
//  CGSize+Utils.swift
//  WeScan
//
//  Created by Julian Schiavo on 17/2/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

import UIKit

extension CGSize {
    /// Calculates an appropriate scale factor which makes the size fit inside both the `maxWidth` and `maxHeight`.
    /// - Parameters:
    ///   - maxWidth: The maximum width that the size should have after applying the scale factor.
    ///   - maxHeight: The maximum height that the size should have after applying the scale factor.
    /// - Returns: A scale factor that makes the size fit within the `maxWidth` and `maxHeight`.
    func scaleFactor(forMaxWidth maxWidth: CGFloat, maxHeight: CGFloat) -> CGFloat {
        if width < maxWidth && height < maxHeight { return 1 }
        
        let widthScaleFactor = 1 / (width / maxWidth)
        let heightScaleFactor = 1 / (height / maxHeight)
        
        // Use the smaller scale factor to ensure both the width and height are below the max
        return min(widthScaleFactor, heightScaleFactor)
    }
    
    func scaleSize(for maxDimension: CGFloat) -> CGSize {
        // 3
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        // 4
        if self.width > self.height {
            scaledSize.height = self.height / self.width * scaledSize.width
        } else {
            scaledSize.width = self.width / self.height * scaledSize.height
        }
        return scaledSize
    }
}
