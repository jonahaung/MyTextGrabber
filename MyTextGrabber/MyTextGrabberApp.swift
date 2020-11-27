//
//  MyTextGrabberApp.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 26/11/20.
//

import SwiftUI

@main
struct MyTextGrabberApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
    }
}
