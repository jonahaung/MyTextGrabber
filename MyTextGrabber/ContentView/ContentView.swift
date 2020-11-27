//
//  ContentView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import SwiftUI
import VisionKit
import UIKit
import CoreData

struct ContentView: View {
    
    let manager = ContentViewManager()
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        VStack {
            List {
                ForEach(items) { item in
                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: deleteItems)
            }
            HStack{
                Spacer()
                Button(action: openPhotoAlbum, label: {
                    Image(systemName: "photo.on.rectangle.angled")
                })
                
                Button(action: openScanner, label: {
                    Image(systemName: "camera.fill")
                })
                Button(action: openDocumentScanner, label: {
                    Image(systemName: "doc.text.viewfinder")
                })
                Spacer()
            }
            .font(.title)
        }.padding()
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

}

extension ContentView {
    
    private func openPhotoAlbum(){
        let x = UIImagePickerController()
        x.sourceType = .photoLibrary
        x.allowsEditing = false
        x.delegate = manager
        UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
    }
    
    private func openScanner() {
        let x = ScannerNavigationController(nil)
        x.modalPresentationStyle = .fullScreen
        UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
    }
    
    private func openDocumentScanner() {
        let x = VNDocumentCameraViewController()
//        x.modalPresentationStyle = .formSheet
        x.delegate = manager
        UIApplication.getTopViewController()?.present(x, animated: true, completion: nil)
    }
}



private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
