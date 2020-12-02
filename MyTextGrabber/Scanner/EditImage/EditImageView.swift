//
//  EditImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI
import UIKit
import Vision

enum ImageFilterMode: CaseIterable {
    case original, grayScaled, blackAndWhite
    
    var description: String {
        switch self {
        case .original:
            return "Original"
        case .grayScaled:
            return "Gray Scale"
        case .blackAndWhite:
            return "Black&White"
        }
    }
}
final class EditingImage: ObservableObject, Identifiable {
    @Published var quad: Quadrilateral?
}


struct EditImageView: View {
    
    @ObservedObject var result: ImageScannerResult
  
    @ObservedObject var editingImage: EditingImage = EditingImage()
    
    var thumbnils = ImageFilterMode.allCases
    
    var body: some View {
        ZStack {
            QuadImageView(quad: $editingImage.quad, image: $result.editedImage)
            VStack {
                Spacer()
                thumbnilsBar()
                bottomBar()
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .accentColor(.white)
    }
}

extension EditImageView {
    
    private func thumbnilsBar() -> some View {
        return HStack(spacing: 10) {
            Spacer()
            ForEach(thumbnils, id: \.self) { item in
                let image = result.thumbnilImage(for: item)
                Button {
                    result.editedImage = image
                } label: {
                    VStack {

                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70)
                    }
                    .padding(.all, 4)
                    .background(Rectangle().fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 2, x: 2, y: 2))
                }
            }
            Spacer()
        }
    }
    
    private func bottomBar() -> some View {
        return HStack(spacing: 10) {
            Button(action: {
                
                result.isEditing = false
            }, label: {
                Image(systemName: "trash.fill")
            })
            Spacer()
            Button(action: {
                if let rotated =  result.editedImage.rotated(by: Measurement(value: -(Double.pi / 2), unit: .radians)) {
                    result.editedImage = rotated
                }
            }, label: {
                Image(systemName: "rotate.left.fill")
            })
            
            Button(action: {
                
                if let rotated =  result.editedImage.rotated(by: Measurement(value: Double.pi / 2.0, unit: .radians)) {
                    result.editedImage = rotated
                }
                
            }, label: {
                Image(systemName: "rotate.right.fill")
            })
            Button(action: {
                editingImage.quad = Quadrilateral(rect: CGRect(x: 0.1, y: 0.2, width: 0.8, height: 0.6))
            }, label: {
                Image(systemName: "selection.pin.in.out")
                    
            })
            Button(action: {
                TextBoxDetector.detect(image: result.editedImage) { textRects in
                    let normalizedRect = textRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
                    let quad = Quadrilateral(rect: normalizedRect)
                    DispatchQueue.main.async {
                        self.editingImage.quad = quad
                    }
                }
            }, label: {
                Image(systemName: "crop")
            })
            Spacer()
            Button(action: {
                guard let quad = editingImage.quad?.applying(CurrentSession.cameraTransform), let ciImage = CIImage(image: result.editedImage) else { return }
                let cgOrientation = CGImagePropertyOrientation(result.editedImage.imageOrientation)
                let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
                let scaledQuad = quad.scale(UIScreen.main.bounds.size, result.editedImage.size)
                var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: result.editedImage.size.height)
                cartesianScaledQuad.reorganize()

                let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                    "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
                    "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
                    "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
                    "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
                ])

                result.editedImage = filteredImage.uiImage ?? UIImage()
                editingImage.quad = nil
                
            }, label: {
                Text("Continue")
            })
        }.font(.title).padding(5).background(Color.black.opacity(0.5))
    }
}
