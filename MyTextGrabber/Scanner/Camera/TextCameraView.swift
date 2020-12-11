//
//  TextCameraView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 3/12/20.
//

import SwiftUI

struct TextCameraView: View {

    @Binding var result: ImageScannerResult
    private let cameraManager = Cameramanager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            TextCameraViewRepresentable(scannedImage: $result.scannedImage, viewState: $result.viewSate, cameraManager: cameraManager)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                bottomBar()
            }
        }
        
        .background(Color.black)
        .accentColor(.white)
        .onAppear {
            cameraManager.viewWillAppear()
            
        }
        .onDisappear {
            cameraManager.viewWillDisappear()
        }
    }
    
    private func bottomBar() -> some View {
        
        return HStack(alignment: .bottom) {
            Spacer()
            Button(action: {
                result.viewSate = .None
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark.circle")
            })
            Spacer()
            Button(action: {
                cameraManager.capture()
            }, label: {
                Image(systemName: "largecircle.fill.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
            })
            Spacer()
            Button(action: {
                cameraManager.capture()
            }, label: {
                Image(systemName: "magnifyingglass")
                    
            })
            Spacer()
        }
        .font(.title)
        .padding()
        
    }
}
