//
//  UtilCloudKit.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/05/18.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit
import CloudKit

class UtilCloudKit: NSObject {

    let keyPredicate = "predicate"
    let keyDevice = "device"
    let myCKContainer = CKContainer.default()
    
    fileprivate var _mySubscription: Any? = nil
    @available(iOS 8.0, *)
    var mySubscription: Any? {
        get {
            if #available(iOS 10.0, *) {
                return _mySubscription as? CKQuerySubscription
            } else {
                return _mySubscription as? CKSubscription
            }
        }
        set {
            _mySubscription = newValue
        }
    }
    
    func createDevicePredicate(deviceName: String) -> NSPredicate {
        let format = (keyDevice + " == '\(deviceName)'")
        print(format)
        
        return NSPredicate(format: format)
    }
    
    func everySingleDevicePredicate() -> [Dictionary<String, Any>] {
        var items = [Dictionary<String, Any>]()
        items.append([keyPredicate: createDevicePredicate(deviceName: "iOS"), keyDevice: "iOS"])

        return items
    }
    
    func replenishDevicePredicates(items: [Dictionary<String, Any>]) {
        UserPreferences.shared.cloudKitSubscriptionPredicate = items
    }
    
    func savePublicSubscription() {
        if #available(iOS 10.0, *) {
            let targetSubscription = mySubscription as! CKQuerySubscription
            myCKContainer.publicCloudDatabase.save(targetSubscription, completionHandler: {
                subscription, error in
                self.handleSaveSubscription(ID: subscription?.subscriptionID, message: subscription.debugDescription, error: error)
            })
        } else {
            let targetSubscription = mySubscription as! CKSubscription
            myCKContainer.publicCloudDatabase.save(targetSubscription, completionHandler: {
                subscription, error in
                self.handleSaveSubscription(ID: subscription?.subscriptionID, message: subscription.debugDescription, error: error)
            })
        }
    }
    
    func fetchPublicSubscription() {
        if !isRegistedSubscription() {
            self.savePublicSubscription()
        } else {
            let ID = UserPreferences.shared.cloudKitSubscriptionID
            myCKContainer.publicCloudDatabase.fetch(withSubscriptionID: ID, completionHandler: { (fetchedSubscription, error) in
                if nil == error {
                    UtilLocalNotification().debugSilentPush(message: fetchedSubscription.debugDescription, funcName: #function, isSuccess: true)
                } else {
                    UtilLocalNotification().debugSilentPush(message: error.debugDescription, funcName: #function, isSuccess: false)
                    self.deletePublicSubscription(subscriptionID: ID)
                }
            })
        }
    }
    
    func deletePublicSubscription(subscriptionID: String) {
        myCKContainer.publicCloudDatabase.delete(withSubscriptionID: subscriptionID) { (deletedID, error) in
            self.handleDebugInfo(error: error, funcName: #function, message: (deletedID != nil ? deletedID! : "nothing"))
            if nil == error {
                self.mySubscription = nil
                UserPreferences.shared.cloudKitSubscriptionID = ""
            }
        }
    }
    
    func deleteAllPublicSubscription() {
        myCKContainer.publicCloudDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if let results = subscriptions {
                for item in results {
                    self.deletePublicSubscription(subscriptionID: item.subscriptionID)
                }
            }
        }
    }
    
    func isRegistedSubscription() -> Bool {
        if !UserPreferences.shared.cloudKitSubscriptionID.isEmpty {
            return true
        }
        
        let predicate = createDevicePredicate(deviceName: "iOS")
        let type = "SilentChecking"
        if #available(iOS 10.0, *) {
            let subscription = CKQuerySubscription(recordType: type, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
            subscription.notificationInfo = createCKNotificationInfo()
            mySubscription = subscription
            UserPreferences.shared.cloudKitSubscriptionID = subscription.subscriptionID
        } else {
            let subscription = CKSubscription(recordType: type, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
            subscription.notificationInfo = createCKNotificationInfo()
            mySubscription = subscription
            UserPreferences.shared.cloudKitSubscriptionID = subscription.subscriptionID
        }
        
        return false
    }
    
    func createCKNotificationInfo() -> CKSubscription.NotificationInfo {
        let info = CKSubscription.NotificationInfo()
        info.soundName = ""
        info.shouldSendContentAvailable = true
        
        return info
    }
    
    func updateAllDeviceRecordObject() {
        let predicates = everySingleDevicePredicate()
        for predicate in predicates {
            let devicePredicate = predicate[keyPredicate] as! NSPredicate
            let deviceName = predicate[keyDevice] as! String
            updateDeviceRecordObject(predicate: devicePredicate, deviceName: deviceName)
        }
    }
    
    func updateSingleRecordObject() {
        var items = UserPreferences.shared.cloudKitSubscriptionPredicate
        if items.count == 0 {
            replenishDevicePredicates(items: everySingleDevicePredicate())
        } else {
            let target = items.endIndex - 1
            let predicate = items[target]
            let devicePredicate = predicate[keyPredicate] as! NSPredicate
            let deviceName = predicate[keyDevice] as! String
            updateDeviceRecordObject(predicate: devicePredicate, deviceName: deviceName)
            items.remove(at: target)
            UserPreferences.shared.cloudKitSubscriptionPredicate = items
        }
    }
    
    func updateDeviceRecordObject(predicate: NSPredicate, deviceName: String) {
        let publicDB = myCKContainer.publicCloudDatabase
        //let privateDatabase : CKDatabase = CKContainer.defaultContainer().privateCloudDatabase
        
        let type = "SilentChecking"
        let query = CKQuery(recordType: type, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if nil == error {
                if let resultRecords = records {
                    print("resultRecords = \(resultRecords)")
                    
                    if resultRecords.count > 0 {
                        self.deleteRecord(publicDatabase: publicDB, record: (resultRecords.last)!)
                        return
                    }
                }
            } else {
                print("error = \(String(describing: error))")
            }
            self.addNewRecord(publicDatabase: publicDB, deviceName: deviceName)
        }
    }
    
    func handleSaveSubscription(ID: String?, message: String, error: Error?) {
        if ID != nil {
            UserPreferences.shared.cloudKitSubscriptionID = ID!
        } else {
            self.deleteAllPublicSubscription()
        }
        self.handleDebugInfo(error: error, funcName: #function, message: message)
    }
    
    func handleDebugInfo(error: Error?, funcName: String, message: String) {
        if error == nil {
            print("Success")
            UtilLocalNotification().debugSilentPush(message: message, funcName: funcName, isSuccess: true)
        } else {
            UtilLocalNotification().debugSilentPush(message: error.debugDescription, funcName: funcName, isSuccess: false)
            print("Error : \(String(describing: error))")
        }
    }
    
    func deleteRecord(publicDatabase: CKDatabase, record: CKRecord) {
        publicDatabase.delete(withRecordID: record.recordID) { (recordId, error) in
            self.handleDebugInfo(error: error, funcName: #function, message: recordId.debugDescription)
        }
    }
    
    func addNewRecord(publicDatabase: CKDatabase, deviceName: String) {
        let type = "SilentChecking"
        let record = CKRecord(recordType: type)
        let key = keyDevice
        let value = deviceName
        record.setObject(value as CKRecordValue?, forKey: key)
        
        publicDatabase.save(record) {
            record, error in
            self.handleDebugInfo(error: error, funcName: #function, message: record.debugDescription)
        }
    }
}
