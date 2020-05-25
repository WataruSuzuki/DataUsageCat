//
//  AppDelegate.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/06/21.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder,
    UNUserNotificationCenterDelegate,
    UIApplicationDelegate
{

    var window: UIWindow?
    
//    var isUnlockAd: Bool = false
    var storyBoardName: String!
    var countAdMobInterstitial: Int = 0
    let recorder = PacketUsageRecorder()
    let packetStore = PacketUsageStore.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NCMB.setApplicationKey(KeyIdNCMB.API, clientKey: KeyIdNCMB.CLIENT)
        FirebaseApp.configure()
        
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        UNUserNotificationCenter.current().delegate = self

        recorder.getNetworkUsageArrayData(context: packetStore.context)
        if let localNotification = launchOptions?[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification {
            handleSilentPushNCMB(notification: localNotification, applicationState: .background)
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let utilNoti = UtilLocalNotification()
        switch response.notification.request.identifier {
        case utilNoti.reqIdRestartDataMonitoring:
            UIApplication.shared.registerForRemoteNotifications()
            
        case utilNoti.reqIdStartWorking:
            UtilNCMB().setNextNCMBSilentPushSchedule()
            
        default:
            break
        }
    }
    
    //#pragma mark - Application's background
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if UserPreferences.shared.silentNotificationSetting {
            #if DEBUG
                UtilCloudKit().updateSingleRecordObject()
            #else
                executeDataUsageCheckingInBackground()
            #endif
        } else {
            application.registerForRemoteNotifications()
            executeDataUsageCheckingInBackground()
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func executeDataUsageCheckingInBackground() {
        recorder.getNetworkUsageArrayData(context: packetStore.context)
        recorder.fetchMonthNetworkUsage(context: packetStore.context)
        
        let queue = OperationQueue()
        queue.addOperation({
            self.recorder.checkRecentLimitUsage()
            OperationQueue.main.addOperation({
                UtilLocalNotification().catRestartDataMonitoring()
            })
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
        if let trigger = notification.request.trigger, trigger.repeats {
            // 繰り返しありの場合は再登録.
            UNUserNotificationCenter.current().add(notification.request) {
                (error_) in
                if let error = error_ {
                    print(error)
                }
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        UIApplication.shared.cancelLocalNotification(notification)
        if !notification.repeatInterval.isEmpty {
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        handleSilentPushNCMB(notification: notification, applicationState: application.applicationState)
    }
    
    func handleSilentPushNCMB(notification: UILocalNotification, applicationState: UIApplication.State) {
        guard notification.alertBody == UtilLocalNotification().bodyCatStartWorking else {
            return
        }
        
        switch applicationState {
        case .active:
            let controller = UIAlertController(title: "", message: notification.alertBody, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: notification.alertAction, style: .default, handler: { (UIAlertAction) in
                UtilNCMB().setNextNCMBSilentPushSchedule()
            }))
            self.window?.rootViewController?.present(controller, animated: true, completion: nil)
            
        default:
            UtilNCMB().setNextNCMBSilentPushSchedule()
        }
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if UserPreferences.shared.silentNotificationSetting {
            UtilNCMB().registDeviceTokenToNCMB(deviceToken: deviceToken)
        } else {
            UtilCloudKit().fetchPublicSubscription()
            Messaging.messaging().apnsToken = deviceToken
        }
    }
    
    func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError err: Error) {
        print(#function)
        print(err.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if UserPreferences.shared.silentNotificationSetting {
            UtilNCMB().setNextNCMBSilentPushSchedule()
            UtilCloudKit().updateSingleRecordObject()
        } else {
            executeDataUsageCheckingInBackground()
            UtilLocalNotification().debugSilentPush(message: userInfo.debugDescription, funcName: #function, isSuccess: true)
        }
        
        completionHandler(.newData)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if UserPreferences.shared.silentNotificationSetting {
            UtilCloudKit().updateAllDeviceRecordObject()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

