//
//  DayNetworkUsage+CoreDataProperties.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/07/03.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import Foundation
import CoreData

extension DayNetworkUsage {

    @nonobjc class func fetchRequest() -> NSFetchRequest<DayNetworkUsage> {
        return NSFetchRequest<DayNetworkUsage>(entityName: "DayNetworkUsage");
    }

    @NSManaged var saved_date: NSDate?
    @NSManaged var wifi_received: NSNumber?
    @NSManaged var wifi_sent: NSNumber?
    @NSManaged var wwan_received: NSNumber?
    @NSManaged var wwan_sent: NSNumber?

}
