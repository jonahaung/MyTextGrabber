//
//  EditImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

struct EditImageView: View {
    
    
    var thumbnils = ImageFilterMode.allCases
    @State private var isShowingThumbnilBar = true
    @State private var isCropping = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var result: ImageScannerResult
   
    
    var body: some View {
        VStack {
            EditImageViewRepresentable(result: result).onTapGesture {
                hideThumbnilBar()
            }
            
            if isShowingThumbnilBar {
                thumbnilsBar()
            }
            
            Spacer()
            if isCropping {
                changesButtonsBar()
            }
            bottomBar()
        }
    }
}

extension EditImageView {
    private func changesButtonsBar() -> some View {
        return HStack{
            Button(action: cancelChangesButtonTapped) {
                Text("Cancel Changes")
                    .frame(height: 40)
                    .padding(.horizontal)
                    .border(Color.accentColor, width: 2)
                    .cornerRadius(5)
                
            }
            Button(action: applayChangesButtonTapped) {
                Text("Apply Changes")
                    .frame(height: 40)
                    .padding(.horizontal)
                    .border(Color.accentColor, width: 2)
                    .cornerRadius(5)
                
            }
        }
    }
    private func thumbnilsBar() -> some View {
        return ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(alignment: .top) {
                ForEach(thumbnils, id: \.self) { item in
        
                    VStack {
                        Button {
                            hideThumbnilBar()
                            result.editedImage = result.thumbnilImage(for: item)
                        } label: {
                            Image(uiImage: result.thumbnilImage(for: item))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80)
                                .background(Rectangle().fill(Color.white).shadow(color: Color.black.opacity(0.2), radius: 2, x: 2, y: 2))
                                .padding(2)
                        }
                    }
                }
                
                Button {
                    withAnimation {
                        isShowingThumbnilBar = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            .font(.title3)
        })
    }
    
    private func bottomBar() -> some View {
        return HStack(alignment: .bottom) {
            Button {
                result.viewSate = .None
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.down.circle")
            }
            Spacer()
            Button(action: {
                withAnimation {
                    isShowingThumbnilBar.toggle()
                    result.quadrilateral = nil
                }
            }, label: {
                Image(systemName: isShowingThumbnilBar ? "paintpalette.fill" : "paintpalette")
                
            })
            Button(action: rotateRight) { Image(systemName: "rotate.right") }
            
            Button(action: selectTextBox) { Image(systemName: "crop") }
            Spacer()
            Button(action: {
                
                result.viewSate = .TextOCRView
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "checkmark.circle.fill")
            })
        }
        .padding().font(.title)
    }
}

// Actions
extension EditImageView {
    
    private func detectTextBox() {
        TextBoxDetector.detect(image: result.editedImage) { textRects in
            let normalizedRect = textRects.map{$0.boundingBox}.reduce(CGRect.null, {$0.union($1)})
            let quad = Quadrilateral(rect: normalizedRect)
            self.result.quadrilateral = quad
        }
    }
    
    private func selectTextBox() {
        withAnimation {
            isShowingThumbnilBar = false
            isCropping = true
        }
        detectTextBox()
    }
    
    private func rotateRight() {
        isShowingThumbnilBar = false
        let rotationAngle = Measurement<UnitAngle>(value: 90, unit: .degrees)
        guard let newImage = result.editedImage.rotated(by: rotationAngle) else { return }
        result.editedImage = newImage
       detectTextBox()
    }
    
    private func applayChangesButtonTapped() {
        withAnimation {
            isCropping = false
           
        }
        cropImageToQuadrilateral()
    }
    private func cropImageToQuadrilateral() {
        guard let quad = result.quadrilateral?.applying(CurrentSession.cameraTransform), let ciImage = CIImage(image: result.editedImage) else { return }
        let cgOrientation = CGImagePropertyOrientation(result.editedImage.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        let scaledQuad = quad.scale(CurrentSession.currentQuadViewSize, result.editedImage.size)
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: result.editedImage.size.height)
        cartesianScaledQuad.reorganize()
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        guard let uiImage = filteredImage.uiImage else { return }
//        guard uiImage.size.width >= 700 || uiImage.size.height >= 700 else {
//            return
//        }
        result.editedImage = uiImage
        result.quadrilateral = nil
        //        result.quadrilateral = Quadrilateral.defaultQuad(allOfImage: result.editedImage).applying(CurrentSession.cameraTransform.inverted())
        detectTextBox()
    }
    private func cancelChangesButtonTapped() {
        withAnimation {
            isCropping = false
        }
        detectTextBox()
    }
    
    private func hideThumbnilBar() {
        withAnimation {
            isShowingThumbnilBar = false
        }
    }
}
