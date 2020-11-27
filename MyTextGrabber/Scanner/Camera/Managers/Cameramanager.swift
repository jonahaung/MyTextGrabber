//
//  OcrManager.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/5/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import UIKit

protocol CameraManagerDelegate: class {
    func cameraManage(_ manager: Cameramanager, didCaptureImage image: UIImage)
}

final class Cameramanager: ObservableObject {
    
    weak var delegate: CameraManagerDelegate?
    var currentTextRects = [TextRect]()
    var cameraView: CameraUIView?
    private let videoService = VideoService()
    let visionService = VisionService()
    
    
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
        
        delegate?.cameraManage(self, didCaptureImage: image)
    }
}

extension Cameramanager: VisionServiceDelegate {
    
    func service(_ service: VisionService, didOutput textRects: [TextRect], buffer: CVImageBuffer) {
        DispatchQueue.main.async {
            self.currentTextRects = textRects
            self.cameraView?.configure(textRects)
        }
    }
}
