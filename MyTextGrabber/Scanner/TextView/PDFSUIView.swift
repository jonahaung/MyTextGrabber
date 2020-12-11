//
//  PDFSUIView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 11/12/20.
//

import SwiftUI
import PDFKit

struct PDFViewRepresentable: UIViewRepresentable {
    
    let text: String
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        let doc = PDFDocument(data: Data(text.utf8))
         pdfView.document = doc
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
       
    }
}
