//
//  TextView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 4/12/20.
//

import SwiftUI
import CoreData

struct TextView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var result: ImageScannerResult
    @State var fontSize: CGFloat = 15
    
    var body: some View {
        VStack{
            TextEditor(text: $result.text)
                .font(Font(UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)))
                .padding()
            bottomBar()
        }
    }
    
    private func bottomBar() -> some View {
        return HStack(alignment: .bottom) {
            
            Spacer()
            Button {
                result.viewSate = .None
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.down.circle")
            }
            Spacer()
            Group {
                Button {
                    fontSize -= 1
                } label: {
                    Image(systemName: "chevron.down.square")
                }
                Button {
                    fontSize += 1
                } label: {
                    Image(systemName: "chevron.up.square")
                }
                Button {
                    result.text = WordSegmentationManager.shared.tag(result.text).map{$0.tag}.joined(separator: " ")
                } label: {
                    Image(systemName: "textformat.alt")
                }
                Button {
                    result.text = result.text
                } label: {
                    Image(systemName: "text.cursor")
                }
                Button {
                    result.text = WordSegmentationManager.shared.tag(result.text).map{$0.tag + "|" + $0.label }.joined(separator: "\t")
                } label: {
                    Image(systemName: "tag")
                }
            }
            
            Spacer()
            Button {
                let time = Date()
                let item = Item(context: viewContext)
                item.text = result.text
                item.timestamp = time
                try? viewContext.save()
                result.viewSate = .None
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "checkmark.circle.fill")
                
            }
            Spacer()
        }.padding().font(.title)
    }
}

struct TextResult {
    var text: String
    var fontSize: CGFloat
}

extension FileManager {
    static func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)
        return documentDirectory[0]
    }
    static func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }
}
