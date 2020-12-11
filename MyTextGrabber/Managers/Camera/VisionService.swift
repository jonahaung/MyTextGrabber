//
//  VisionService.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/5/20.
//  Copyright © 2020 Aung Ko Min. All rights reserved.
//

import AVKit
import Vision

protocol VisionServiceDelegate: class {
    func service(_ service: VisionService, didOutput textRects: [TextRect])
}

class VisionService: NSObject {
    
    weak var delegate: VisionServiceDelegate?
    private var lastTimestamp = CMTime()
    private var fps = 10
    
    deinit {
        print("VisionService")
    }
    
}


extension VisionService {
    private func textCompletionHandler(request: VNRequest?, error:Error?) {
        guard let results = request?.results as? [VNRecognizedTextObservation] else { return }
        let textRects = results.map{TextRect(observation: $0)}.compactMap{$0}
        self.delegate?.service(self, didOutput: textRects)
    }
}

extension VisionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        let canPerformRequest = deltaTime >= CMTimeMake(value: 1, timescale: Int32(fps))
        
        if canPerformRequest {
            CurrentSession.videoSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            self.lastTimestamp = timestamp
            detectText(buffer)
        }
    }
    
    func detectText(_ pixelBuffer: CVImageBuffer) {
        
        let textRequest = VNRecognizeTextRequest(completionHandler: textCompletionHandler(request:error:))
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        try? handler.perform([textRequest])
    }
    
}
