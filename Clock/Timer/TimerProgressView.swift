//
//  TimerProgressView.swift
//  Clock
//
//  Created by GNR on 11/8/22.
//

import SwiftUI

struct LoadingCircle: Shape, Animatable {
    var progress: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: min(rect.width * 0.5, rect.height * 0.5), startAngle: .degrees(0), endAngle: .degrees(360 * progress), clockwise: false)
        return path
    }
}

struct TimerProgressView: View {
    @EnvironmentObject var timerManager: TimerManager

    var body: some View {
        ZStack {
            LoadingCircle(progress: timerManager.progress)
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundColor(.orange)
                .frame(width: 300, height: 300)
                .animation(.linear(duration: 1.0), value: timerManager.progress)
            
            Text(self.timerManager.counter.timeLabel())
                .foregroundColor(.white)
                .frame(width: 300)
                .font(.system(size: 60))
        }
    }
}

struct TimerProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TimerProgressView()
    }
}
