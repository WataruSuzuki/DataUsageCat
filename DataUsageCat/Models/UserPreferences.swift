//
//  UserPreferences.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2014/08/20.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

class UserPreferences: NSObject {
    static let shared: UserPreferences = {
        return UserPreferences()
    }()

    private override init() {
    }

    private let ud = UserDefaults.standard
    
    private struct Default {
        static let limit_usage_value = Float(7.0)
        static let reset_to_month = true
        static let reset_of_chart = false
        static let reset_of_day = 1
        static let usage_notification = false
        
        static let silent_notification = false
        static let update_coredata = false
        static let cloudkit_subscription_id = ""
        static let cloudkit_subscription_predicate = NSKeyedArchiver.archivedData(withRootObject: [Dictionary<String, Any>]())
        
        static let debug_cloudkit_silent_push = false
        static let debug_legacy_subscription = false
    }
    
    var usageNotificationSetting: Bool {
        get {
            ud.register(defaults: ["usage_notification": Default.usage_notification])
            return ud.bool(forKey: "usage_notification")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "usage_notification")
            ud.synchronize()
        }
    }
    
    var silentNotificationSetting: Bool {
        get {
            ud.register(defaults: ["silent_notification": Default.silent_notification])
            return ud.bool(forKey: "silent_notification")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "silent_notification")
            ud.synchronize()
        }
    }
    
    var limitUsageValue: Float {
        get {
            ud.register(defaults: ["limit_usage_value": Default.limit_usage_value])
            return ud.float(forKey: "limit_usage_value")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "limit_usage_value")
            ud.synchronize()
        }
    }
    
    var resetOfMonth: Bool {
        get {
            ud.register(defaults: ["reset_to_month": Default.reset_to_month])
            return ud.bool(forKey: "reset_to_month")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "reset_to_month")
            ud.synchronize()
        }
    }
    
    var resetOfDay: Int {
        get {
            ud.register(defaults: ["reset_of_day": Default.reset_of_day])
            return ud.integer(forKey: "reset_of_day")
        }
        set(newDay) {
            ud.set(newDay, forKey: "reset_of_day")
            ud.synchronize()
        }
    }
    
    var chartDisp2Month: Bool {
        get {
            ud.register(defaults: ["reset_of_chart": Default.reset_of_chart])
            return ud.bool(forKey: "reset_of_chart")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "reset_of_chart")
            ud.synchronize()
        }
    }
    
    var updateCoreData: Bool {
        get {
            ud.register(defaults: ["update_coredata": Default.update_coredata])
            return ud.bool(forKey: "update_coredata")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "update_coredata")
            ud.synchronize()
        }
    }
    
    var cloudKitSubscriptionID: String {
        get {
            ud.register(defaults: ["cloudkit_subscription_id": Default.cloudkit_subscription_id])
            return ud.string(forKey: "cloudkit_subscription_id")!
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "cloudkit_subscription_id")
            ud.synchronize()
        }
    }
    
    var cloudKitSubscriptionPredicate: [Dictionary<String, Any>] {
        get {
            ud.register(defaults: ["cloudkit_subscription_predicate": Default.cloudkit_subscription_predicate])
            if let data = ud.data(forKey: "cloudkit_subscription_predicate") {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as! [Dictionary<String, Any>]
            } else {
                return [Dictionary<String, Any>]()
            }
        }
        set(nextValue) {
            let data = NSKeyedArchiver.archivedData(withRootObject: nextValue)
            ud.set(data, forKey: "cloudkit_subscription_predicate")
            ud.synchronize()
        }
    }
    
    var debugCloudKitSilentPush: Bool {
        get {
            ud.register(defaults: ["debug_cloudkit_silent_push": Default.debug_cloudkit_silent_push])
            return ud.bool(forKey: "debug_cloudkit_silent_push")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "debug_cloudkit_silent_push")
            ud.synchronize()
        }
    }
    
    var debugLegacySubscription: Bool {
        get {
            ud.register(defaults: ["debug_legacy_subscription": Default.debug_legacy_subscription])
            return ud.bool(forKey: "debug_legacy_subscription")
        }
        set(nextValue) {
            ud.set(nextValue, forKey: "debug_legacy_subscription")
            ud.synchronize()
        }
    }
}
