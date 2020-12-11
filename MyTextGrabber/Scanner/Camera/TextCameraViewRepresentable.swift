//
//  CustomCameraView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

struct TextCameraViewRepresentable: UIViewRepresentable {
    
    @Binding var scannedImage: UIImage?
    @Binding var viewState: ViewState
    @Environment(\.presentationMode) var presentationMode
    let cameraManager: Cameramanager
    
    func makeUIView(context: Context) -> CameraUIView {
        let view = CameraUIView()
        cameraManager.cameraView = view
        cameraManager.delegate = context.coordinator
        cameraManager.setup()
        return view
    }

    
    func updateUIView(_ uiView: CameraUIView, context: Context) {
       
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(scannedImage: $scannedImage, presentationMode: presentationMode, viewState: $viewState)
    }
}

internal class Coordinator: NSObject, CameraManagerDelegate {
    
    private var scannedImage: Binding<UIImage?>
    private var presentationMode: Binding<PresentationMode>
    private var viewState: Binding<ViewState>
    init(scannedImage: Binding<UIImage?>, presentationMode: Binding<PresentationMode>, viewState: Binding<ViewState>) {
        self.presentationMode = presentationMode
        self.scannedImage = scannedImage
        self.viewState = viewState
    }
    
    func cameraManage(_ manager: Cameramanager, didCaptureImage image: UIImage) {
        scannedImage.wrappedValue = image
        viewState.wrappedValue = .ImageEditorView
        presentationMode.wrappedValue.dismiss()
    }
}
