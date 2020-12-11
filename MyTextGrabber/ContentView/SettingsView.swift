//
//  SettingsView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 5/12/20.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false
    @EnvironmentObject var userDefaults: UserDefaultsManager
    
    @State var isOn = true
    var body: some View {
        Form {
            Section {
                HStack {
                    Label("Language", systemImage: "globe")
                    Spacer()
                    Button {
                        userDefaults.languageMode = userDefaults.languageMode.toggle
                    } label: {
                        Text(userDefaults.languageMode.description)
                    }
                }
                
                Button {
                    hasShownOnboarding.toggle()
                } label: {
                    Label("Onboarding", systemImage: "figure.walk")
                }
            }
            Section {
                HStack {
                    Label("Language", systemImage: "globe")
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("Bluh")
                    }
                }
                
                Button {
                    hasShownOnboarding.toggle()
                } label: {
                    Label("Onboarding", systemImage: "figure.walk")
                }
            }
        }
      
        .navigationTitle("Settings")
    }
}
