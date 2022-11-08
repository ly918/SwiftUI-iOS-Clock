//
//  TimerManager.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import Foundation
import SwiftUI

final class TimerManager: ObservableObject {
    private(set) var timer: Timer?
    
    var totalCount: Int {
        return hour * 60 * 60 + minute * 60 + second
    }
    
    var hour: Int {
        return Int(self.selection[0])!
    }
    var minute: Int {
        return Int(self.selection[1])!
    }
    var second: Int {
        return Int(self.selection[2])!
    }

    @Published var selection = [0, 0, 5].map({"\($0)"}) {
        didSet {
            self.counter = self.totalCount
        }
    }

    @Published var data: [(String, [String])] = [
        ("Hour", Array(0...23).map({"\($0)"})),
        ("Minute", Array(0...60).map({"\($0)"})),
        ("Second", Array(0...60).map({"\($0)"})),
    ]
    
    @Published var state: TimerState = .ready
    @Published var counter = 0 {
        didSet {
            self.startDisabled = self.totalCount == 0
            self.progress = Double(counter) / Double(totalCount)
        }
    }
    @Published var startDisabled: Bool = false
    @Published var sound: Sound = .radar
    @Published var progress: Double = 1.0

    init() {
        self.removeNotification()
    }

    func start() {
        self.timer?.invalidate()
        self.state = .action
        self.counter = self.totalCount
        self.timer = Timer(fire: .now + 0.5, interval: 1, repeats: true, block: { [self] _ in
            DispatchQueue.main.async {
                print(self.counter)
                if self.counter > 0 {
                    self.state = .action
                    self.counter -= 1
                } else {
                    self.stop()
                }
            }
        })
        RunLoop.current.add(self.timer!, forMode: .common)
        self.removeNotification()
        self.addNotification()
    }
    
    func pause() {
        self.timer?.fireDate = .distantFuture
        self.state = .paused
    }
    
    func resume() {
        self.timer?.fireDate = .distantPast
        self.state = .action
    }
    
    func cancel() {
        self.stop()
        removeNotification()
    }
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        self.state = .ready
    }
}

enum TimerState {
    case ready
    case action
    case paused
    
    var cancelText: String {
        return "Cancel"
    }
    
    var cancelDisabled: Bool {
        return self == .ready
    }
    
    var cancelTextColor: Color {
        return Color.white.opacity(self.cancelDisabled ? 0.5 : 1)
    }
    
    var cancelBgColor: Color {
        return Color.gray.opacity(self.cancelDisabled ? 0.2 : 0.4)
    }
    
    var startText: String {
        switch self {
        case .ready: return "Start"
        case .action: return "Pause"
        case .paused: return "Resume"
        }
    }
    
    var startTextColor: Color {
        if self == .action {
            return .orange
        }
        return .green
    }
    
    var startBgColor: Color {
        if self == .action {
            return .orange.opacity(0.4)
        }
        return .green.opacity(0.4)
    }
}

let timerId = "Timer"
extension TimerManager {
    func addNotification() {
        NotificationManager.shared.addNotification(NotificationManager.shared.notificationContent("Alarm", "Timer", nil, self.sound.named, nil), timerId, NotificationManager.shared.trigger(interval: TimeInterval(self.totalCount), false), false) { error in
            print("add timer notification \(error?.localizedDescription ?? "")")
        }
    }
    
    func removeNotification() {
        NotificationManager.shared.removeNotification([timerId])
    }
}

extension Int {
    func timeLabel() -> String {
        if self/3600 > 0 {
            return String(format: "%02d:%02d:%02d", self/3600, (self%3600)/60, (self%3600)%60)
        }
        return String(format: "%02d:%02d", (self%3600)/60, (self%3600)%60)
    }
}
