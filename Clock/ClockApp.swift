//
//  ClockApp.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

@main
struct ClockApp: App {
    @StateObject var alarmManager = AlarmManager()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .onAppear {
                    NotificationManager.shared.registerLoaclNotification()
                }
                .preferredColorScheme(.dark)
                .environmentObject(alarmManager)
        }
    }
}
