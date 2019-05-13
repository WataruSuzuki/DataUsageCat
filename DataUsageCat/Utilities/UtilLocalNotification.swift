//
//  UtilLocalNotification.swift
//  DataUsageCat
//
//  Created by 鈴木 航 on 2016/05/18.
//  Copyright © 2016年 鈴木 航. All rights reserved.
//

import UIKit
import UserNotifications

class UtilLocalNotification: NSObject {
    
    let catVeryDelighting = "(=・ω・=)...\n"
    let catSmiling = "(=・∀・=)\n"
    let catSurprised = "(=・A・=)!!\n"
    let bodyCatStartWorking = "ニャンコお仕事するニャ"
    let bodySilentIsWorking = "ニャンコは今日もちゃんとお仕事しているニャン"
    let bodyAlertRecentUsage = NSLocalizedString("local_notification_alert_body", comment:"")
    
    let actionAlert = NSLocalizedString("local_notification_alert_action", comment:"")
    
    let reqIdRestartDataMonitoring = "RestartDataMonitoring"
    let reqIdStartWorking = "StartWorking"
    
    let secOneDay = (60 * 60 * 24)

    func setAlertRecentUsageNotification() {
        let date = Date()
        let ud = UserDefaults.standard
        ud.set(date, forKey: "alerted_date")
        ud.synchronize()
        
        setLocalNotification(date: date, title: catSurprised, subTitle: "", body: bodyAlertRecentUsage, action: actionAlert, soundName: "meow.wav", requestIdentifier: "AlertRecentUsage")
    }
    
    func catStartWorkingSilentPush() {
        setLocalNotification(date: Date(), title: catVeryDelighting, subTitle: "", body: bodyCatStartWorking, action: actionAlert, soundName: "", requestIdentifier: reqIdStartWorking)
    }
    
    func catWorkingNow() {
        setLocalNotification(date: Date(), title: catSmiling, subTitle: "", body: bodySilentIsWorking, action: actionAlert, soundName: "", requestIdentifier: "WorkingNow")
    }
    
    @available(iOS 10.0, *)
    func catRestartDataMonitoring() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reqIdRestartDataMonitoring])
        let interval = TimeInterval(secOneDay * 2)
        setLocalNotification(date: Date.init(timeIntervalSinceNow: interval), title: NSLocalizedString("title_not_work_recently", comment:""), subTitle: "", body: NSLocalizedString("msg_not_work_recently", comment:""), action: actionAlert, soundName: "", requestIdentifier: reqIdRestartDataMonitoring)
    }
    
    func debugSilentPush(message: String, funcName: String, isSuccess: Bool) {
        #if DEBUG
            let isDisp = true
        #else
            let isDisp = UtilUserDefaults().debugCloudKitSilentPush
        #endif//DEBUG
        if isDisp {
            let catEmotion = (isSuccess ? catSmiling : catSurprised)
            setLocalNotification(date: Date(), title: catEmotion, subTitle: funcName, body: message, action: "", soundName: "", requestIdentifier: funcName)
        }
    }
    
    func isNeedRecentUsageNotification() -> Bool {
        //var ret: Bool = false
        //var ud: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let lastAlertedDate = UserDefaults.standard.object(forKey: "alerted_date") as! Date
        if NSDate().timeIntervalSince(lastAlertedDate) > TimeInterval(secOneDay) {
            return true
        }
        NSLog("alerted recently...")
        
        return false
    }
    
    func getNotificationPermittedStatus(status: @escaping ((_ isPermitted: Bool) -> Void)) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .denied:
                    status(true)
                case .notDetermined:
                    self.reqAuthNotification()
                    fallthrough
                default:
                    status(false)
                }
            }
        } else {
            let types = UIApplication.shared.currentUserNotificationSettings?.types
            if let result = (types?.contains(.alert)) {
                status(!result)
            }
            status(true)
        }
    }
    
    private func setLocalNotification(date:Date, title: String, subTitle: String, body: String, action: String, soundName: String, requestIdentifier: String) {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subTitle
            content.body = body
            if !soundName.isEmpty {
                content.sound = UNNotificationSound(named: soundName)
            }
            
            let time = date.timeIntervalSince(Date())
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (time > 0 ? time : 1), repeats: false)
            
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) {
                (error_) in
                if let error = error_ {
                    print(error)
                }
            }
        } else {
            let notification:UILocalNotification = UILocalNotification()
            notification.fireDate = date
            if #available(iOS 8.2, *) {
                notification.alertTitle = title
            }
            notification.alertBody = title + subTitle + body
            notification.alertAction = action
            notification.soundName = soundName
            //notification.userInfo = ["notification_id": notification_id]
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    @available(iOS 10.0, *)
    func reqAuthNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                self.showConfirmNotificationPermission()
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func registUserNotification(application: UIApplication)  {
        if #available(iOS 10.0, *) {
            //do nothing
        } else {
            let notificationSetting = UIUserNotificationSettings(types: [UIUserNotificationType.badge, UIUserNotificationType.sound, UIUserNotificationType.alert], categories: nil)
            application.registerUserNotificationSettings(notificationSetting)
        }
    }
    
    func showConfirmNotificationPermission() {
        let controller = UIAlertController(title: NSLocalizedString("title_ignore_notification", comment:""), message: NSLocalizedString("msg_ignore_notification", comment:""), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: actionAlert, style: .default, handler: { (UIAlertAction) in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }))
        controller.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment:""), style: .cancel, handler: nil))
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.window?.rootViewController?.present(controller, animated: true, completion: nil)
        }
    }
}
