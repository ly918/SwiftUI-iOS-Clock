//
//  RootTabView.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

struct RootTabView: View {

    var body: some View {
        TabView {
            AlarmView()
                .tag(0)
                .tabItem {
                    Image(systemName: "clock")
                    Text("Alarm")
                }
            
            TimerView()
                .tag(1)
                .tabItem {
                    Image(systemName: "timer")
                    Text("Timer")
                }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
    }
}
