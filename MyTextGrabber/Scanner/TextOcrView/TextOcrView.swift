//
//  TextOcrView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 3/12/20.
//

import SwiftUI

struct TextOcrView: View {
    
    @ObservedObject var manager = TextOcrManager()
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var result: ImageScannerResult
   
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                TextOcrViewRepresentable(result: result, textRects: manager.textRects)
                VStack {
                    Spacer()
                    HStack{
                        Spacer()
                        loadingCircle()
                    }
                }
                .padding()
            }
            bottomBar()
        }
    }
    private func loadingCircle() -> some View {
        return HStack {
            Spacer()
            ZStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0.0, to: min(manager.progress/manager.totalProgress, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.white)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)
                    
                }
                .frame(width: 80, height: 80)
                
                Image(systemName: "\(min(manager.totalProgress.int - manager.progress.int, 50)).circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                
            }
            .foregroundColor(.accentColor)
            .frame(width: 90, height: 90)
        }
    }
    private func bottomBar() -> some View {
        
        return HStack(alignment: .bottom) {
            Spacer()
            Button {
                guard !manager.isProcessingText else { return }
                result.viewSate = .None
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.down.circle")
            }
            Spacer()
            Button(action: {
                manager.detectTextBoxes(for: result.editedImage)
            }, label: {
                Image(systemName: "largecircle.fill.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 55)
                
            })
            .disabled(manager.isProcessingText)
            
            
            Spacer()
            Button {
                result.text = manager.textResult.text
                result.viewSate = .TextView
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                
            }
            Spacer()
        }
        .padding()
        .font(.title)
    }
}
