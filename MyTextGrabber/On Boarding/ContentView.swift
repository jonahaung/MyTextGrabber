//
//  OnBoarding.swift
//  Food
//
//  Created llby BqNqNNN on 7/12/20.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @AppStorage("hasShownOnboarding") private var hasShownOnboarding: Bool = false
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .link
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }
    var body: some View {
        NavigationView {
            if hasShownOnboarding {
                HomeView()
            }else {
                OnboardingView().navigationBarHidden(true)
            }
           
        }
    }
}
