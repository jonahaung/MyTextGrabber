//
//  TextRect.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/5/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
import Vision

private let context = CIContext()

class TextRect {
    
    let text: String?
    
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
    
    var boundingBox: CGRect
    
    var image: UIImage?
    
    var recognizedText: String?
    
    init?(observation: VNRecognizedTextObservation) {
        guard let first = observation.topCandidates(1).first else { return nil }
        let string = first.string
        text = string
        let stringRange = string.startIndex..<string.endIndex
        let boxObservation = try! first.boundingBox(for: stringRange)
        topLeft = boxObservation?.topLeft ?? .zero
        topRight = boxObservation?.topRight ?? .zero
        bottomLeft = boxObservation?.bottomLeft ?? .zero
        bottomRight = boxObservation?.bottomRight ?? .zero
        
        boundingBox = boxObservation?.boundingBox ?? .zero
    }
    
    private var path: UIBezierPath {
        let transform = CurrentSession.cameraTransform
        let path = UIBezierPath()
        path.move(to: topLeft.applying(transform))
        path.addLine(to: topRight.applying(transform))
        path.addLine(to: bottomRight.applying(transform))
        path.addLine(to: bottomLeft.applying(transform))
        path.close()
        
        return path
    }
    
    private lazy var shapeLayer: CAShapeLayer = {
        $0.shadowColor = UIColor.systemYellow.cgColor
        $0.shadowOpacity = 0.3
        $0.shadowOffset = .zero
        $0.shadowRadius = 0
        $0.shouldRasterize = true
        $0.rasterizationScale = UIScreen.main.scale
        return $0
    }(CAShapeLayer())
    
    lazy var textLayer: CATextLayer = {
        $0.contentsScale = UIScreen.main.scale
        $0.isWrapped = true
        $0.shouldRasterize = true
        $0.rasterizationScale = UIScreen.main.scale
        return $0
    }(CATextLayer())
    
    func addShapeLayer(to _layer: CALayer) {
        _layer.addSublayer(shapeLayer)
        shapeLayer.shadowPath = path.cgPath
    }
    
    func addTextLayer(to _layer: CALayer) {
        _layer.addSublayer(textLayer)
    }
    func remove() {
        shapeLayer.removeFromSuperlayer()
        textLayer.removeFromSuperlayer()
    }
    
    func cropImage(ciImage: CIImage) {
    
        let imageSize = ciImage.extent.size
        let imageWidth = Int(imageSize.width)
        let imageHeight = Int(imageSize.height)
        let bottomLeft = VNImagePointForNormalizedPoint(self.bottomLeft, imageWidth, imageHeight)
        let bottomRight = VNImagePointForNormalizedPoint(self.bottomRight, imageWidth, imageHeight)
        let topLeft = VNImagePointForNormalizedPoint(self.topLeft, imageWidth, imageHeight)
        let topRight = VNImagePointForNormalizedPoint(self.topRight, imageWidth, imageHeight)
        
        let filteredImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
        if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
            image = UIImage(cgImage: cgImage)
        }
    }
    
    func display() {
        guard let text = self.recognizedText ?? self.text, let boundingBox = shapeLayer.shadowPath?.boundingBoxOfPath else { return }
        
        let colors = image?.getColors()
        let isMyanmar = UserDefaultsManager.shared.languageMode != .English
        let factor: CGFloat = isMyanmar ? 0.7 : 0.9
        let fontSize = max(8, (boundingBox.height * factor))
        let font = UIFont.myanmarFont.withSize(fontSize)
        
        let textFrame = text.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: boundingBox.height), options: [.usesFontLeading], attributes: [.font: font], context: nil)
        let textSize = textFrame.size
        
        CATransaction.setDisableActions(true)
        shapeLayer.shadowOpacity = 1
        shapeLayer.shadowColor = colors?.background.cgColor
        shapeLayer.isHidden = false
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = UIColor.darkText.cgColor
        
        textLayer.frame = textFrame
        textLayer.string = text
        if textSize.width > boundingBox.width {
            let scaleX = boundingBox.size.width/textSize.width
            let scaleY = boundingBox.size.height*factor/textSize.height
            let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            textLayer.setAffineTransform(scaleTransform)
        }
        textLayer.frame.origin = boundingBox.origin
        textLayer.setNeedsDisplay()
    }
    
    deinit {
        
    }
}
