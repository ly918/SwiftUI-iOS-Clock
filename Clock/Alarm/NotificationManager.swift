//
//  NotificationManager.swift
//  Clock
//
//  Created by GNR on 11/7/22.
//

import Swift
import UserNotifications
import CoreLocation

let actionFiveMin = "fiveMinutes"
let actionHalfAnHour = "halfAnHour"
let actionOneHour = "OneHour"
let actionStop = "stopCancel"
let categoryLaterId = "categoryLaterId"
let categoryStopId = "categoryStopId"

class NotificationManager: NSObject {
    static let shared = NotificationManager()
    private var center: UNUserNotificationCenter {
        get {
            UNUserNotificationCenter.current()
        }
    }
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    func registerLoaclNotification() {
        // request authorization
        center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            print("request authorization \(granted)")
            if let err = error {
                print(err.localizedDescription)
            }
        }
        center.getNotificationSettings { settings in
            print("settings \(settings)")
        }
        
        // set categories
        let action1 = UNNotificationAction(identifier: actionFiveMin, title: "After 5 min", options: UNNotificationActionOptions.authenticationRequired)
        let action2 = UNNotificationAction(identifier: actionHalfAnHour, title: "After half an hour", options: UNNotificationActionOptions.authenticationRequired)
        let action3 = UNNotificationAction(identifier: actionOneHour, title: "After one hour", options: UNNotificationActionOptions.authenticationRequired)
        let action4 = UNNotificationAction(identifier: actionStop, title: "Stop", options: UNNotificationActionOptions.authenticationRequired)
        let catogary = UNNotificationCategory(identifier: categoryLaterId, actions: [action1, action2, action3, action4], intentIdentifiers: [])
        let stopCategary = UNNotificationCategory(identifier: categoryStopId, actions: [action4], intentIdentifiers: [])
        center.setNotificationCategories([catogary, stopCategary])
        center.delegate = self
    }
}

// MARK: - Notifications
extension NotificationManager {
    func addNotification(_ request: UNNotificationRequest, _ completionHandler: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            self.semaphore.wait()
            self.getAllNotificationIdentifer { ids in
                if ids.count >= 64 {
                    self.semaphore.signal()
                    return
                }
                self.center.add(request) { error in
                    self.semaphore.signal()
                    completionHandler(error)
                }
            }
        }
    }
    
    func addNotification(_ content: UNNotificationContent, _ identifer: String, _ trigger: UNNotificationTrigger, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        let mContent: UNMutableNotificationContent = content.mutableCopy() as! UNMutableNotificationContent
        mContent.categoryIdentifier = isLater ? categoryLaterId : categoryStopId
        self.addNotification(UNNotificationRequest(identifier: identifer, content: mContent, trigger: trigger), completionHandler)
    }
    
    func addNotification(_ content: UNNotificationContent, _ deteComponents: DateComponents , _ identifer: String, _ isRepeat: Bool, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        self.addNotification(content, identifer, self.trigger(dateComponents: deteComponents, isRepeat), isLater, completionHandler)
    }
    
    func addNotification(_ content: UNNotificationContent, _ interval: TimeInterval , _ identifer: String, _ isRepeat: Bool, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        self.addNotification(content, identifer, self.trigger(interval: interval, isRepeat), isLater, completionHandler)
    }
    
    func addNotification(_ content: UNNotificationContent, _ weekDay: Int , _ date: Date, _ identifer: String, _ isRepeat: Bool, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        self.addNotification(content, self.components(date, weekDay: weekDay), identifer, isRepeat, isLater, completionHandler)
    }
    
    func addNotification(_ body: String, _ title: String, _ weekDay: Int, _ date: Date, _ sound: String, _ identifer: String, _ isRepeat: Bool, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        let content = self.notificationContent(title, body, nil, sound, nil)
        self.addNotification(content, weekDay, date, identifer, isRepeat, isLater, completionHandler)
    }
    
    func addNotification(_ body: String, _ title: String, _ dateComponents: DateComponents, _ sound: String, _ identifer: String, _ isRepeat: Bool, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        let content = self.notificationContent(title, body, nil, sound, nil)
        self.addNotification(content, dateComponents, identifer, isRepeat, isLater, completionHandler)
    }
    
    func addNotificationEveryDay(_ body: String, _ title: String, _ date: Date, _ sound: String, _ identifer: String, _ isLater: Bool, _ completionHandler: @escaping ((Error?) -> Void)) {
        let content = self.notificationContent(title, body, nil, sound, nil)
        self.addNotification(content, self.componentsEveryDay(date), identifer, true, isLater, completionHandler)
    }
    
    func removeNotification(_ identifers: [String]) {
        self.center.removeDeliveredNotifications(withIdentifiers: identifers)
        self.center.removePendingNotificationRequests(withIdentifiers: identifers)
    }
    
    func isExistNotification(_ identifer: String, _ completionHandler: @escaping ((Bool) -> Void)) {
        self.getAllNotificationIdentifer { ids in
            completionHandler(ids.firstIndex(where: {$0 == identifer}) != nil)
        }
    }
    
    func getAllNotificationIdentifer(_ closure: @escaping (([String]) -> Void)) {
        self.center.getDeliveredNotifications { notifications in
            let ids = notifications.map { $0.request.identifier }
            self.center.getPendingNotificationRequests { requests in
                let ids1 = requests.map { $0.identifier }
                closure(ids+ids1)
            }
        }
    }
    
    func getDeliveredNotificationIdentifers(_ completionHandler: @escaping (([String]) -> Void)) {
        self.center.getDeliveredNotifications { notifications in
            completionHandler(notifications.map { $0.request.identifier })
        }
    }
    
    func getPendingNotificationIdentifers(_ completionHandler: @escaping (([String]) -> Void)) {
        self.center.getPendingNotificationRequests { requests in
            completionHandler(requests.map { $0.identifier })
        }
    }
}

// MARK: - NSDateComponents -
extension NotificationManager {
    func notificationContent(_ title: String = "Alarm", _ body: String = "") -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        return content
    }
    
    func notificationContent(_ title: String, _ body: String, _ badge: Int?, _ sound: String?, _ attachments: [UNNotificationAttachment]?) -> UNMutableNotificationContent {
        let content = self.notificationContent(title, body)
        if let badge = badge {
            content.badge = NSNumber(value: UInt(badge))
        }
        if let sound = sound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(sound))
        }
        if let attachments = attachments {
            content.attachments = attachments
        }
        return content
    }
}

// MARK: - NSDateComponents -
extension NotificationManager {
    func components(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
    
    func components(_ date: Date, weekDay: Int) -> DateComponents {
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.weekday = weekDay
        return dateComponents
    }
    
    func componentsEveryDay(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: date)
    }
    
    func componentsEveryWeek(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
    }
    
    func componentsEveryMonth(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.day, .hour, .minute], from: date)
    }
        
    func componentsEveryYear(_ date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.month, .day, .hour, .minute], from: date)
    }
}

// MARK: - UNNotificationTrigger -
extension NotificationManager {
    func trigger(region: CLRegion, _ repeats: Bool) -> UNNotificationTrigger {
        return UNLocationNotificationTrigger(region: region, repeats: repeats)
    }
    
    func trigger(interval: TimeInterval, _ repeats: Bool) -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
    }
    
    func trigger(dateComponents: DateComponents, _ repeats: Bool) -> UNNotificationTrigger {
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
    }
}

extension NotificationManager {
    func soundName(_ name: String) -> UNNotificationSound {
        return UNNotificationSound(named: UNNotificationSoundName(name))
    }
}

// MARK: - UNUserNotificationCenterDelegate -
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .badge, .list, .banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if !(response.notification.request.trigger is UNPushNotificationTrigger) {
            self.handleResponse(response)
        }
    }
    
    func handleResponse(_ response: UNNotificationResponse) {
        let idf = response.actionIdentifier
        var date: Date?
        if idf == actionStop {
            return
        } else if idf == actionFiveMin {
            date = Date(timeIntervalSinceNow: 5 * 60)
        } else if idf == actionHalfAnHour {
            date = Date(timeIntervalSinceNow: 30 * 60)
        } else if idf == actionOneHour {
            date = Date(timeIntervalSinceNow: 60 * 60)
        }
        guard let date = date else {
            return
        }
        self.addNotification(response.notification.request.content, response.notification.request.identifier, self.trigger(dateComponents: self.components(date), false), true) { error in
            print("add later notification \(error?.localizedDescription ?? "")")
        }
    }
}
