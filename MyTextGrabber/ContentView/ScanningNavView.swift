//
//  ScanningNavView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 11/12/20.
//

import SwiftUI

struct ScanningNavView: View {
    
    @ObservedObject var result: ImageScannerResult
    @State var showImageEditorView = true
    var body: some View {
        NavigationView{
            
//            NavigationLink(destination: EditImageView(image: result.editedImage), isActive: $showImageEditorView) {
//                EmptyView()
//            }
        }
    }
}

