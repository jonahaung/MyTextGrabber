//
//  QuadImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 2/12/20.
//

import SwiftUI
import UIKit
import AVFoundation

struct QuadImageView: UIViewRepresentable {
    
    @Binding var quad: Quadrilateral?
    @Binding var image: UIImage

    
    func makeUIView(context: Context) -> QuadImageUIView {
        let view = QuadImageUIView()
        view.quadView.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: QuadImageUIView, context: Context) {
        let videoRect = AVMakeRect(aspectRatio: image.size, insideRect: uiView.imageView.bounds)
        let visible = videoRect.intersection(uiView.imageView.frame)
        let scaleT = CGAffineTransform(scaleX: visible.width, y: -visible.height)
        let translateT = CGAffineTransform(translationX: visible.minX, y: visible.maxY)
        CurrentSession.cameraTransform = scaleT.concatenating(translateT)
        uiView.imageView.image = image
        uiView.quadView.drawQuadrilateral(quad: quad?.applying(CurrentSession.cameraTransform), animated: false)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(quad: $quad)
    }

    class Coordinator: NSObject, QuadrilateralViewDelegate {
        
        var quad: Binding<Quadrilateral?>
        
        init(quad: Binding<Quadrilateral?>) {
            self.quad = quad
        }
        func quadrilateralView(_ view: QuadrilateralView, quadrilateralDidUpdate quad: Quadrilateral?) {
            self.quad.wrappedValue = quad?.applying(CurrentSession.cameraTransform.inverted())
        }
    }
    
}

class QuadImageUIView: UIView {
    
    let imageView: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    
    
    let quadView: QuadrilateralView = {
        $0.editable = true
        return $0
    }(QuadrilateralView())
    
    private var zoomGestureController: ZoomGestureController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = bounds
        addSubview(imageView)
        addSubview(quadView)
        
        isUserInteractionEnabled = true
        zoomGestureController = ZoomGestureController(imageView: imageView, quadView: quadView)
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0.2
        addGestureRecognizer(touchDown)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        quadView.frame = imageView.frame
    }

}

