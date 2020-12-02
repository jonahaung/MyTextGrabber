//
//  SwiftyTesseract.swift
//  Myanmar Lens
//
//  Created by Aung Ko Min on 20/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//


import AVFoundation
import UIKit

protocol VideoServiceDelegate: class {
    func videoService(_ service: VideoService, didCapturePhoto image: UIImage)
}

final class VideoService: NSObject {
    
    let captureSession = AVCaptureSession()
    private let dataOutputQueue = DispatchQueue(label: "VideoService", autoreleaseFrequency: .workItem)
    private let sessionQueue = DispatchQueue(label: "CaptureSession", autoreleaseFrequency: .workItem)
    private let captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    private let videoOutput: AVCaptureVideoDataOutput = {
        $0.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        return $0
    }(AVCaptureVideoDataOutput())
    private let photoOutput = AVCapturePhotoOutput()
    weak var delegate: VideoServiceDelegate?
    
    override init() {
        super.init()
        setup()
    }
    deinit {
        captureSession.stopRunning()
        print("Video Service")
    }
    
    
}


// Configurations
extension VideoService {
    
    func setup(service: Cameramanager) {
        let layer = service.cameraView?.cameraLayer
        layer?.videoGravity = .resize
        layer?.session = captureSession
        videoOutput.setSampleBufferDelegate(service.visionService, queue: dataOutputQueue)
    }
    private func setup() {
        guard
            isAuthorized(for: .video),
            let device = self.captureDevice,
            let captureDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(captureDeviceInput),
            captureSession.canAddOutput(photoOutput) else {
            return
        }
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        photoOutput.isHighResolutionCaptureEnabled = true
        
        captureSession.addInput(captureDeviceInput)
        configureVideoOutput()
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
    
        
        try? device.lockForConfiguration()
        
        defer {
            device.unlockForConfiguration()
        }
        device.isSubjectAreaChangeMonitoringEnabled = true
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    
    private func configureVideoOutput() {
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        
        let connection = videoOutput.connection(with: .video)
        if connection?.isVideoStabilizationSupported == true {
            connection?.preferredVideoStabilizationMode = .auto
        }else {
            connection?.preferredVideoStabilizationMode = .off
        }
        connection?.videoOrientation = .portrait
        
    }
    
    private func isAuthorized(for mediaType: AVMediaType) -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            return true
        case .notDetermined:
            requestPermission(for: mediaType)
            return false
        default:
            return false
        }
    }
    
    private func requestPermission(for mediaType: AVMediaType) {
        
        dataOutputQueue.suspend()
        AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
            guard let self = self else { return }
            if granted {
                self.setup()
                self.dataOutputQueue.resume()
            }
        }
    }
    
    internal func capturePhoto() {
        guard let connection = photoOutput.connection(with: .video), connection.isEnabled, connection.isActive else {
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
//        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

extension VideoService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let image = UIImage(data: imageData)?.applyingPortraitOrientation() else {
                    return
                }
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.videoService(self, didCapturePhoto: image)
                    
                }
                
            }
        }
    }
}

// Actions
extension VideoService {
    
    func start() {
        captureSession.startRunning()
    }
    func stop(){
        captureSession.stopRunning()
    }
    func sliderValueDidChange(_ value: Float) {
        do {
            try captureDevice?.lockForConfiguration()
            var zoomScale = CGFloat(value * 10.0)
            let zoomFactor = captureDevice?.activeFormat.videoMaxZoomFactor
            
            if zoomScale < 1 {
                zoomScale = 1
            } else if zoomScale > zoomFactor! {
                zoomScale = zoomFactor!
            }
            captureDevice?.videoZoomFactor = zoomScale
            captureDevice?.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
            captureDevice?.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
            captureDevice?.unlockForConfiguration()
        } catch {
            print("captureDevice?.lockForConfiguration() denied")
        }
    }
}
