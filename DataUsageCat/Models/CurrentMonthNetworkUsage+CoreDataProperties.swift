//
//  CurrentMonthNetworkUsage+CoreDataProperties.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/07/03.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import Foundation
import CoreData

extension CurrentMonthNetworkUsage {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CurrentMonthNetworkUsage> {
        return NSFetchRequest<CurrentMonthNetworkUsage>(entityName: "CurrentMonthNetworkUsage");
    }

    @NSManaged var index: NSNumber?
    @NSManaged var last_boot_time: NSNumber?
    @NSManaged var last_save_time: NSDate?
    @NSManaged var wifi_received: NSNumber?
    @NSManaged var wifi_sent: NSNumber?
    @NSManaged var wwan_received: NSNumber?
    @NSManaged var wwan_sent: NSNumber?

}
