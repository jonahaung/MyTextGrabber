//
//  Location.swift
//  Food
//
//  Created by BqNqNNN on 7/12/20.
//

import SwiftUI

struct Location: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Image("location")
                    .resizable()
                    .scaledToFit()
                Text("Hi, nice to meet you !")
                    .font(.title)
                    .bold()
                Text("Choose your location to find \nrestraurants around you. ")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                    .padding(.all, 20)
                Button {
                    UserDefaults.standard.set(true, forKey: "hasShownOnboarding")
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.accentColor)
                        
                        Text("Use current location")
                            .bold()
                            .foregroundColor(.accentColor)
                        
                    }
                    .frame(width: 300, height: 60, alignment: .center)
                    .border(Color.accentColor, width: 3)
                    .cornerRadius(5)
                }
                Text("Select Manually")
                    .bold()
                    .underline()
                    .foregroundColor(.gray)
                    .padding(.top, 80)
                Spacer()
            }
        }
    }
}
