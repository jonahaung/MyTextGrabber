//
//  HomeView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 1/12/20.
//

import SwiftUI

struct HomeView: View {
    
    @State var showScanner = false
    
    @State var result = ImageScannerResult()
    
    @EnvironmentObject var userDefaults: UserDefaultsManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    var body: some View {
        VStack{
            topBar()
            recentItems()
            Spacer()
            Menu()
            
            bottomBar()
        }
        .navigationTitle("MyScanner")
        .fullScreenCover(isPresented: $showScanner) {
            showScanner = false
            check()
        } content: {
            switch result.viewSate {
            
            case .PhotoAlbum:
                ImagePickerView(result: $result)
            case .CustomScanner:
                TextCameraView(result: $result)
            case .DocScanner:
                DocumentScannerView(result: $result)
            case .ImageEditorView:
                EditImageView(result: result)
            case .TextOCRView:
                TextOcrView(result: result)
            case .TextView:
                TextView(result: result)
            case .None:
                WelcomeView()
            }
        }
    }
    
}

extension HomeView {
    
    private func recentItems() -> some View {
        return VStack {
            
            HStack {
                Text("Recents")
                    .bold()
                    .multilineTextAlignment(.trailing)
                    .padding(.leading, 20)
                
                Spacer()
                NavigationLink(destination: SavedItemsView()) {
                    Text("View all >")
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, 20)
                }
                
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .center, spacing: 5, content: {
                    ForEach(items) { item in
                        
                        NavigationLink(destination: TextView(result: ImageScannerResult(text: item.text ?? ""))) {
                            VStack {
                                Text(item.text ?? "")
                                    .lineLimit(20)
                                   
                                    .font(.system(size: 7))
                                    .lineSpacing(0)
                                    .padding(8)
                                    .foregroundColor(.primary)
                            }
                            .background(Rectangle().fill(Color(.systemBackground)).shadow(color: Color(.separator), radius: 3, x: 2, y: 2))
                            .frame(width: 120)
                        }
                    }
                })
            }.frame(height: 220)
        }
        .padding(.vertical)
        .background(Rectangle().fill(Color(.systemBackground)).shadow(color: Color(.separator), radius: 3, x: 2, y: 2))
    }
    
    private func topBar() -> some View {
        return HStack {
            Spacer()
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "scribble")
                    .padding(8)
                    .background(Circle().fill(Color(.systemBackground)).shadow(color: Color(.separator), radius: 2, x: 2, y: 2))
            }

            
        }
        .font(.title)
        .padding()
        
    }
    
    private func bottomBar() -> some View {
        return HStack {
            
            Button {
                userDefaults.languageMode = userDefaults.languageMode.toggle
            } label: {
                Text(userDefaults.languageMode.description)
                    .font(.title)
                    .padding(22)
                    .background(Circle().fill(Color(.systemBackground)).shadow(color: Color(.separator), radius: 2, x: 2, y: 2))
            }
            
            Spacer()
            
        }
        .padding()
        
    }
    
    private func Menu() -> some View {
        return HStack {
            Button(action: openScanner, label: {
                Image(systemName: "camera.viewfinder")
                    .padding(10)
                    .background(Circle().fill(Color.blue).shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 2, x: 2, y: 2))
            })
            Button(action: openPhotoAlbum, label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .padding(10)
                    .background(Circle().fill(Color.blue).shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 2, x: 2, y: 2))
            })
            Button(action: openDocumentScanner, label: {
                Image(systemName: "doc.text.fill.viewfinder")
                    .padding(10)
                    .background(Circle().fill(Color.blue).shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 2, x: 2, y: 2))
            })
            
        }
        .font(.largeTitle)
        .accentColor(Color(.systemBackground))
        .padding()
    }

}

extension HomeView {
    
    private func check() {
        if result.viewSate == .None {
            result = ImageScannerResult()
        } else {
            showScanner = true
        }
    }
    
    private func openPhotoAlbum(){
        
        result.viewSate = .PhotoAlbum
        
        showScanner = true
    }
    
    private func openScanner() {
        result.viewSate = .CustomScanner
        showScanner = true
    }
    
    private func openDocumentScanner() {
        result.viewSate = .DocScanner
        showScanner = true
    }
}
