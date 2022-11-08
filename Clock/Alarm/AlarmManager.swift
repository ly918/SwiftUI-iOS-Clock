//
//  AlarmManager.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import Foundation
import SwiftUI

@MainActor final class AlarmManager: ObservableObject {
    
    @Published private(set) var alarms: [Alarm] = []
    
    init() {
        self.unarchive()
    }
    
    func isEdit(_ id: String) -> Bool {
        if let _ = self.alarms.firstIndex(where: {$0.id == id}) {
            return true
        } else {
            return false
        }
    }
    
    func add(_ alarm: Alarm?) {
        guard let alarm = alarm else {
            return
        }
        alarms.append(alarm)
        if alarm.isOn {
            addNotification(alarm)
        }
        archive()
    }
    
    func update(_ alarm: Alarm?) {
        guard let alarm = alarm else {
            return
        }
        guard let index = alarms.firstIndex(where: {$0.id == alarm.id}) else {
            return
        }
        alarms[index] = alarm
        updateNotification(alarm)
        archive()
    }
    
    func remove(alarm: Alarm?) {
        guard let alarm = alarm else {
            return
        }
        guard let index = alarms.firstIndex(where: {$0.id == alarm.id}) else {
            return
        }
        alarms.remove(at: index)
        removeNotification(alarm)
        archive()
    }
    
    func remove(indexSet: IndexSet) {
        let alarm = alarms.remove(at: indexSet.first!)
        remove(alarm: alarm)
    }
    
    func toggle(_ alarm: Alarm) {
        guard let index = alarms.firstIndex(where: {$0.id == alarm.id}) else {
            return
        }
        alarms[index].isOn.toggle()
        if alarms[index].isOn {
            addNotification(alarm)
        } else {
            removeNotification(alarm)
        }
        archive()
    }
}

extension AlarmManager {
    
    func addNotification(_ alarm: Alarm) {
        if alarm.selectRepeats.count == Alarm.repeats.count {// every day
            NotificationManager.shared.addNotification(alarm.label, Alarm.labelPlaceholder, NotificationManager.shared.componentsEveryDay(alarm.time), alarm.sound.named, alarm.id, alarm.isRepeat, alarm.isLater) { error in
                print("add every day alarm \(error?.localizedDescription ?? "")")
            }
        } else if alarm.selectRepeats.count == 0 {
            NotificationManager.shared.addNotification(alarm.label, Alarm.labelPlaceholder, NotificationManager.shared.components(alarm.time), alarm.sound.named, alarm.id, alarm.isRepeat, alarm.isLater) { error in
                print("add alarm \(error?.localizedDescription ?? "")")
            }
        } else {
            for repeatStr in alarm.selectRepeats {
                let index = Alarm.repeats.firstIndex(where: {$0 == repeatStr})!
                let week = index + 1
                NotificationManager.shared.addNotification(alarm.label, Alarm.labelPlaceholder, week, alarm.time, alarm.sound.named, alarm.id, alarm.isRepeat, alarm.isLater) { error in
                    print("add week day alarm \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func updateNotification(_ alarm: Alarm) {
        self.removeNotification(alarm)
        if alarm.isOn {
            self.addNotification(alarm)
        }
    }
    
    func removeNotification(_ alarm: Alarm) {
        NotificationManager.shared.removeNotification([alarm.id])
        print("remove alarm")
    }
}

let archiveKey = "archiveKey"

extension AlarmManager {
    
    final func archive() {
        DispatchQueue.global().async {
            do {
                let encode = PropertyListEncoder()
                let data = try encode.encode(self.alarms)
                UserDefaults.standard.set(data, forKey: archiveKey)
            } catch {
                print("archive error!")
            }
        }
    }
    
    final func unarchive() {
        DispatchQueue.global().async {
            do {
                guard let data: Data = UserDefaults.standard.object(forKey: archiveKey) as? Data else {
                    return
                }
                let decoder = PropertyListDecoder()
                let alarms:[Alarm] = try decoder.decode([Alarm].self, from: data)
                DispatchQueue.main.async {
                    self.alarms = alarms
                }
            } catch {
                print("unarchive error!")
            }
        }
    }
}
