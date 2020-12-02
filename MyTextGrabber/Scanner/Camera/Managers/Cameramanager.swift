//
//  OcrManager.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/5/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit
import Vision

protocol CameraManagerDelegate: class {
    func cameraManage(_ manager: Cameramanager, didCaptureImage image: UIImage)
}

final class Cameramanager: ObservableObject {
    
    weak var delegate: CameraManagerDelegate?
    var cameraView: CameraUIView?
    private let videoService = VideoService()
    let visionService = VisionService()
    private var currentTextRects = [TextRect]()
    
    func setup() {
        videoService.delegate = self
        visionService.delegate = self
        videoService.setup(service: self)
    }
    
    func viewWillAppear() {
        videoService.start()
    }
    func viewWillDisappear() {
        videoService.stop()
    }
    
    func capture() {
        videoService.capturePhoto()
    }
}

extension Cameramanager: VideoServiceDelegate {
    
    
    func videoService(_ service: VideoService, didCapturePhoto image: UIImage) {
        cropToTexts(image: image)
    }
    
    private func cropToTexts(image: UIImage) {
        guard !currentTextRects.isEmpty else { return }
        let boundingBox = currentTextRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
        let imageRect = VNImageRectForNormalizedRect(boundingBox.normalized(), image.size.width.int, image.size.height.int)
        guard
            let pixelBuffer = image.pixelBuffer(),
            let cgImage = CGImage.create(pixelBuffer: pixelBuffer),
            let cropped = cgImage.cropping(to: imageRect)
        else {
            print("no pixel buffer")
            return
        }
        
        let uiImage = UIImage(cgImage: cropped, scale: 1, orientation: .up)
        delegate?.cameraManage(self, didCaptureImage: uiImage)
    }
}

extension Cameramanager: VisionServiceDelegate {
    
    func service(_ service: VisionService, didOutput textRects: [TextRect]) {
        DispatchQueue.main.async {
            self.cameraView?.configure(textRects)
            self.currentTextRects = textRects
        }
        
    }
}
