//
//  ProgressCircleView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 3/12/20.
//

import SwiftUI

struct ProgressCircle: View {

    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 3)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
                    
        }.frame(height: 30)
    }
}
