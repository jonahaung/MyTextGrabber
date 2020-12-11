//
//  CameraView.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/5/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraUIView: UIView {
    
    private var currentTextRects = [TextRect]()
    override class var layerClass: AnyClass { return AVCaptureVideoPreviewLayer.self }
    var cameraLayer: AVCaptureVideoPreviewLayer { return layer as! AVCaptureVideoPreviewLayer }

    private let shapeLayer: CAShapeLayer = {
        $0.fillColor = nil
        $0.strokeColor = UIColor.systemYellow.cgColor
        $0.lineWidth = 2
        return $0
    }(CAShapeLayer())
    
    private let animation: CABasicAnimation = {
        $0.duration = 0.25
        return $0
    }(CABasicAnimation())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTransform()
    }
    
    deinit {
        currentTextRects.removeAll()
    }
}

extension CameraUIView {
    
    private func updateTransform() {
        let videoRect = CGRect(origin: .zero, size: CurrentSession.videoSize)
        let visible = videoRect.intersection(frame)
        let scaleT = CGAffineTransform(scaleX: visible.width, y: -visible.height)
        let translateT = CGAffineTransform(translationX: visible.minX, y: visible.maxY)
        CurrentSession.cameraTransform = scaleT.concatenating(translateT)
    }
    
    
    func configure(_ textRects: [TextRect]) {
        if shapeLayer.path == nil {
            updateTransform()
        }
        
        currentTextRects.forEach{$0.remove()}
    
        let normalizedRect = textRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)}).applying(CurrentSession.cameraTransform).scaleAndCenter(withRatio: 1.1)
        shapeLayer.add(animation, forKey: "path")
        shapeLayer.path = CGMutablePath(rect: normalizedRect, transform: nil)
    
        self.currentTextRects = textRects
    }
    
    private func setup() {
        layer.addSublayer(shapeLayer)
    }
}
