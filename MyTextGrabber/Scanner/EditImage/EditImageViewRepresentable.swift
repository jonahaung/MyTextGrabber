//
//  QuadImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 2/12/20.
//

import SwiftUI
import UIKit
import AVFoundation

struct EditImageViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var result: ImageScannerResult
    
    func makeUIView(context: Context) -> QuadImageUIView {
        let view = QuadImageUIView()
        view.quadView.delegate = context.coordinator
        return view
    }

    
    func updateUIView(_ uiView: QuadImageUIView, context: Context) {
        uiView.image = result.editedImage
        uiView.setNeedsLayout()
        uiView.quad = result.quadrilateral?.applying(CurrentSession.cameraTransform)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(quad: $result.quadrilateral, result: result)
    }

    class Coordinator: NSObject, QuadrilateralViewDelegate {
        
        var quad: Binding<Quadrilateral?>
        var result: ImageScannerResult
        init(quad: Binding<Quadrilateral?>, result: ImageScannerResult) {
            self.quad = quad
            self.result = result
        }
        
        func quadrilateralView(_ view: QuadrilateralView, quadrilateralDidUpdate quad: Quadrilateral?) {
            self.quad.wrappedValue = quad?.applying(CurrentSession.cameraTransform.inverted())
        }
    }
}

class QuadImageUIView: UIView {
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            
        }
    }
    
    var quad: Quadrilateral? {
        get {
            return quadView.quad
        }
        set {
            quadView.drawQuadrilateral(quad: newValue)
        }
    }

    private let imageView: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    deinit {
        print("quad image view")
    }
    
    let quadView: QuadrilateralView = {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.separator.cgColor
        $0.editable = true
        return $0
    }(QuadrilateralView())

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = bounds
        addSubview(imageView)
        imageView.addSubview(quadView)
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handle(gesture:)))
        panGesture.minimumPressDuration = 0.1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = image else {
            return }
        let imageFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadView.frame = imageFrame
        CurrentSession.videoSize = image.size
        CurrentSession.currentQuadViewSize = imageFrame.size
        let scaleT = CGAffineTransform(scaleX: quadView.bounds.width, y: -quadView.bounds.height)
        let translateT = CGAffineTransform(translationX: quadView.bounds.minX, y: quadView.bounds.maxY)
        CurrentSession.cameraTransform = scaleT.concatenating(translateT)
    }
    
    private var previousPanPosition: CGPoint?
    private var closestCorner: CornerPosition?
}

extension QuadImageUIView: UIGestureRecognizerDelegate {
    
    
    @objc func handle(gesture: UIGestureRecognizer) {
        
        guard let drawnQuad = quad else {
            return
        }
        guard let image = image else {
            return
        }
        
        guard gesture.state != .ended else {
            previousPanPosition = nil
            closestCorner = nil
            quadView.resetHighlightedCornerViews()
            return
        }
        
        let position = gesture.location(in: quadView)
        
        let previousPanPosition = self.previousPanPosition ?? position
        let closestCorner = self.closestCorner ?? position.closestCornerFrom(quad: drawnQuad)
        
        let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
        let cornerView = quadView.cornerViewForCornerPosition(position: closestCorner)
        let draggedCornerViewCenter = cornerView.center.applying(offset)
        
        quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
        
        self.previousPanPosition = position
        self.closestCorner = closestCorner
        
        let scale = image.size.width / quadView.bounds.size.width
        let scaledDraggedCornerViewCenter = CGPoint(x: draggedCornerViewCenter.x * scale, y: draggedCornerViewCenter.y * scale)
        guard let zoomedImage = image.scaledImage(atPoint: scaledDraggedCornerViewCenter, scaleFactor: 5, targetSize: quadView.bounds.size) else {
            return
        }
        
        quadView.highlightCornerAtPosition(position: closestCorner, with: zoomedImage)
    }
}

