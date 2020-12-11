//
//  OcrImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 3/12/20.
//


import SwiftUI

struct TextOcrViewRepresentable: UIViewRepresentable {

    @ObservedObject var result: ImageScannerResult
    var textRects: [TextRect]
    
    
    func makeUIView(context: Context) -> OcrUIImageView {
        let view = OcrUIImageView()
        return view
    }

    
    func updateUIView(_ uiView: OcrUIImageView, context: Context) {
        uiView.image = result.editedImage
        uiView.setNeedsLayout()
        uiView.draw(textRects)
    }
}
