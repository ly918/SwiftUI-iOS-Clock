//
//  Alarm.swift
//  Clock
//
//  Created by GNR on 11/4/22.
//

import SwiftUI

let sounds: [Sound] = [.radar, .apex]

enum Sound: String, Codable {
    case radar = "Radar"
    case apex = "Apex"
    
    var named: String {
        switch self {
        case .radar: return "sound1.caf"
        case .apex: return "sound2.caf"
        }
    }
}

struct Alarm: Identifiable, Codable {
    static let repeats: [Repeat] = [.sun, .mon, .tues, .wed, .thur, .fri, .sat]
    static let labelPlaceholder = "Alarm"
    
    var id: String = UUID().uuidString
    var label: String = ""
    var isOn: Bool = true
    var isLater: Bool = true
    var time: Date = Date()
    var sound: Sound = .radar
    var selectRepeats: [Repeat] = []
    var intro: String {
        get {
            return (label.count > 0 ? label : Alarm.labelPlaceholder) + ", " + repeatLabel
        }
    }
    
    var isRepeat: Bool {
        return self.selectRepeats.count > 0
    }
    
    var repeatLabel: String {
        if self.selectRepeats.isEmpty {
            return "Never"
        }
        if self.selectRepeats.count == 1 {
            return self.selectRepeats.first!.singleLabel
        }
        if self.selectRepeats.count == Alarm.repeats.count {
            return "Every day"
        }
        return self.selectRepeats.map({$0.simpleLabel}).joined(separator: " ")
    }
    
    var description: String {
        return "\(self.label) \(self.time.timeFormat()) \(sound) \(self.isLater)"
    }
    
    enum Repeat: String, Codable {
        case sun = "Sunday"
        case mon = "Monday"
        case tues = "Tuesday"
        case wed = "Wednesday"
        case thur = "Thursday"
        case fri = "Friday"
        case sat = "Saturday"
        
        var singleLabel: String {
            return "Every" + " " + self.rawValue
        }
        
        var simpleLabel: String {
            switch self {
            case .sun: return "Sun"
            case .mon: return "Mon"
            case .tues: return "Tue"
            case .wed: return "Wed"
            case .thur: return "Thu"
            case .fri: return "Fri"
            case .sat: return "Sat"
            }
        }
    }
}

extension Alarm {
    mutating func selectRepeat(_ item: Alarm.Repeat) {
        if let index = self.selectRepeats.firstIndex(where: {item == $0}) {
            self.selectRepeats.remove(at: index)
        } else {
            self.selectRepeats.append(item)
        }
    }
    
    mutating func isSelectedRepeat(_ item: Alarm.Repeat) -> Bool {
        return self.selectRepeats.firstIndex(where: {item == $0}) != nil
    }
}

extension Date {
    func timeFormat() -> String {
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        return format.string(from: self)
    }
    
    func notificationId() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyyMMddhhmmss"
        return format.string(from: self)
    }
}
