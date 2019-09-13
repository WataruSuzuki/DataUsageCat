//
//  AppDelegate.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/06/21.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
* converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
* original source: AppDelegateObjC.h, AppDelegateObjC.m
*/


import UIKit
//import CoreData
import UserNotifications
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder,
    UNUserNotificationCenterDelegate,
    UIApplicationDelegate
{

    var window: UIWindow?

    //TODO -> var utilNADView: DJKUtilNendAd?
    //var utilADGMngrVC: DJKUtilADGMngrVC!
    
    var isUnlockAd: Bool = false
    var storyBoardName: String!
    var countAdMobInterstitial: Int = 0
    let recorder = PacketUsageRecorder()
    let packetStore = PacketUsageStore.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NCMB.setApplicationKey(KeyIdNCMB.API, clientKey: KeyIdNCMB.CLIENT)
        FirebaseApp.configure()
        
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            UtilLocalNotification().registUserNotification(application: application)
        }
        
        recorder.getNetworkUsageArrayData(context: packetStore.context)
        isUnlockAd = false
        //TODO -> utilNADView = DJKUtilNendAd()
        //TODO -> utilNADView?.initNADInterstitial(KeyIdNend.KEY_INTERSTITIAL, withSpodId: KeyIdNend.ID_INTERSTITIAL)
        //utilADGMngrVC = DJKUtilADGMngrVC()
        
        if #available(iOS 10, *) {
            //do nothing.
        } else {
            if let localNotification = launchOptions?[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification {
                handleSilentPushNCMB(notification: localNotification, applicationState: .background)
            }
        }
        return true
    }
    
    @available(iOS 10.0, *)
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
        if UtilUserDefaults().silentNotificationSetting {
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
                // (UIの更新はメインスレッドから行う必要がある)
                if #available(iOS 10, *) {
                    UtilLocalNotification().catRestartDataMonitoring()
                }
            })
        })
    }
    
    @available(iOS 10.0, *)
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
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if UtilUserDefaults().silentNotificationSetting {
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
        if UtilUserDefaults().silentNotificationSetting {
            UtilNCMB().setNextNCMBSilentPushSchedule()
            UtilCloudKit().updateSingleRecordObject()
        } else {
            executeDataUsageCheckingInBackground()
            UtilLocalNotification().debugSilentPush(message: userInfo.debugDescription, funcName: #function, isSuccess: true)
        }
        
        completionHandler(.newData)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //TODO -> utilNADView?.notifyBannerPause()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //TODO -> utilNADView?.notifyBannerResume(utilNADView?.nend_BannerView)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if UtilUserDefaults().silentNotificationSetting {
            UtilCloudKit().updateAllDeviceRecordObject()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    func updateValueUnLockAd() {
        isUnlockAd = false
        //TODO -> utilNADView?.isUnlockAd = isUnlockAd
        //utilADGMngrVC!.isUnlockAd = isUnlockAd
    }
}

