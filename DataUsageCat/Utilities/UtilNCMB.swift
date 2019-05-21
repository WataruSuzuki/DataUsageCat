//
//  UtilNCMB.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/05/18.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit
//import NCMB

class UtilNCMB: NSObject {

    func setNextNCMBSilentPushSchedule() {
        #if DEBUG
            let intervalTime = Double(60 * 2 * 1)
        #else//DEBUG
            let intervalTime = Double(60 * 60 * 24)
        #endif//DEBUG
        setDeliveryNCMBPush(intervalTime: intervalTime)
    }
    
    func registPollingPushScheduleFromWataru() {
        for minites in 1..<60 {
            let intervalTime = Double(60 * 10 * minites)
            setDeliveryNCMBPush(intervalTime: intervalTime)
        }
    }
    
    func setDeliveryNCMBPush(intervalTime: Double) {
        guard UtilUserDefaults().silentNotificationSetting else {
            return
        }
        let push = NCMBPush()
        
        let query = NCMBQuery()
        query.whereKey("deviceToken", equalTo: NCMBInstallation.current().deviceToken)
        push.setSearchCondition(query)
        
        let pushData = ["contentAvailable": true, "sound": ""] as [String : Any]
        push.setData(pushData)
        push.setDeliveryTime(Date.init(timeIntervalSinceNow: intervalTime))
        
        push.sendInBackground { (error) in
            if nil != error {
                print(error!.localizedDescription)
            } else {
                UtilLocalNotification().catWorkingNow()
            }
        }
    }
    
    func handleSaveInBackgroundWithBlock(error: Error?) {
        if nil != error {
            print(error!.localizedDescription)
            UtilLocalNotification().debugSilentPush(message: error!.localizedDescription, funcName: #function, isSuccess: false)
        } else {
            UtilLocalNotification().catStartWorkingSilentPush()
        }
    }
    
    func registDeviceTokenToNCMB(deviceToken: Data) {
        if let installation = NCMBInstallation.current() {
            installation.setDeviceTokenFrom(deviceToken)
            
            installation.saveInBackground { (error) in
                if nil != error {
                    switch error!._code {
                    case 409001:
                        self.updateExistInstallation(currentInstallation: installation)
                        return
                    case 404001:
                        self.reRegistInstallation(currentInstallation: installation)
                        return
                        
                    default:
                        break
                    }
                }
                self.handleSaveInBackgroundWithBlock(error: error)
            }
        }
    }
    
    func updateExistInstallation(currentInstallation: NCMBInstallation) {
        if let installationQuery = NCMBInstallation.query() {
            installationQuery.whereKey("deviceToken", equalTo: currentInstallation.deviceToken)
            
            installationQuery.getFirstObjectInBackground { (object, error) in
                if nil != error {
                    print(error!.localizedDescription)
                    UtilLocalNotification().debugSilentPush(message: error!.localizedDescription, funcName: #function, isSuccess: false)
                } else {
                    if let searchDevice = object as? NCMBInstallation {
                        currentInstallation.objectId = searchDevice.objectId
                        currentInstallation.saveInBackground({ (error) in
                            self.handleSaveInBackgroundWithBlock(error: error)
                        })
                    }
                }
            }
        }
    }
    
    func reRegistInstallation(currentInstallation: NCMBInstallation) {
        let reInstallation = currentInstallation
        reInstallation.objectId = nil
        reInstallation.saveInBackground { (error) in
            self.handleSaveInBackgroundWithBlock(error: error)
        }
    }
}
