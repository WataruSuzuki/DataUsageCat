//
//  PacketUsageRecorder.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/05/20.
//  Copyright (c) 2015年 Wataru Suzuki. All rights reserved.
//

/*
 * "Hello Swift, Goodbye Obj-C."
 * Converted by 'objc2swift'
 *
 * https://github.com/yahoojapan/objc2swift
 */

import UIKit
import CoreData

class PacketUsageRecorder: NSObject {
    
    let DUC_PRODUCT_ID_UNLOCK_ALL_AD = "jp.co.JchanKchan.DataUsageCat.unlock_all_ad"
    let LIMIT_RECENT_USAGE = Int64(700000000)//((1000000000LL - 300000000LL))
    var arrayUsageLastMonth: [AnyObject]?
    var arrayUsageThisMonth: [AnyObject]?
    var dataUsageCount: DUCNetworkInterFace?
    var lastSavedUsageCount: DUCNetworkInterFace?

    func updateNetworkUsageManagedObj(cmnu: CurrentMonthNetworkUsage, updateType: UpdateType, updateTargetIndex: DataIndex, newUsageData: DUCNetworkInterFace, context: NSManagedObjectContext) {
        
        if UpdateType.new != updateType {
            #if ENABLE_SWIFT_LOG
                print("updateNetworkUsageManagedObj updateTarget = \(updateTargetIndex)")
                print("updateNetworkUsageManagedObj managedObject = \(cmnu)")
                print("updateNetworkUsageManagedObj UPDATE_TYPE_REFLESH")
            #endif//ENABLE_SWIFT_LOG
        } else {
            #if ENABLE_SWIFT_LOG
                print("updateNetworkUsageManagedObj UPDATE_TYPE_NEW")
            #endif//ENABLE_SWIFT_LOG
        }
        let managedObject = getManagedObject(updateData: newUsageData, target: cmnu, targetIndex: updateTargetIndex)
        
        do {
            try managedObject.managedObjectContext!.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        //return managedObject
    }
    
    func createNetworkUsageManagedObj(usageData: DUCNetworkInterFace, withManagedObj context: NSManagedObjectContext) {
        let objCurrent = NSEntityDescription.insertNewObject(forEntityName: "CurrentMonthNetworkUsage", into: context) as! CurrentMonthNetworkUsage
        self.updateNetworkUsageManagedObj(cmnu: objCurrent, updateType: UpdateType.new, updateTargetIndex: DataIndex.current, newUsageData: usageData, context: context)
        
        let objOffset = NSEntityDescription.insertNewObject(forEntityName: "CurrentMonthNetworkUsage", into: context) as! CurrentMonthNetworkUsage
        self.updateNetworkUsageManagedObj(cmnu: objOffset, updateType: UpdateType.new, updateTargetIndex: DataIndex.offset, newUsageData: usageData, context: context)
    }
    
    func getNetworkInterFaceFromCMNU(target: CurrentMonthNetworkUsage) -> DUCNetworkInterFace {
        let fallbackValue = Int64(0)
        
        let wifiSend = (target.wifi_sent?.int64Value ?? fallbackValue)
        let wifiReceived = (target.wifi_received?.int64Value ?? fallbackValue)
        let wwanSend = (target.wwan_sent?.int64Value ?? fallbackValue)
        let wwanReceived = (target.wwan_received?.int64Value ?? fallbackValue)
        
        return DUCNetworkInterFace(
            wifiSend: wifiSend,
            wifiReceived: wifiReceived,
            wwanSend: wwanSend,
            wwanReceived: wwanReceived,
            dateStr: ""
        )
    }
    
    func getDateComponents(date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }
    
    private func getNextRecord(beforeDataCount: DUCNetworkInterFace, newDataCount: DUCNetworkInterFace) -> DUCNetworkInterFace {
        let wifiSend = newDataCount.wifiSend - beforeDataCount.wifiSend
        let wifiReceived = newDataCount.wifiReceived - beforeDataCount.wifiReceived
        let wwanSend = newDataCount.wwanSend - beforeDataCount.wwanSend
        let wwanReceived = newDataCount.wwanReceived - beforeDataCount.wwanReceived
        let dateStr = beforeDataCount.dateStr
        
        return DUCNetworkInterFace(
            wifiSend: wifiSend,
            wifiReceived: wifiReceived,
            wwanSend: wwanSend,
            wwanReceived: wwanReceived,
            dateStr: dateStr
        )
    }
    
    func checkBootTimeAndIfDataResult(last_boot_time: Double) -> Bool {
        if last_boot_time >= ProcessInfo.processInfo.systemUptime {
            return true
        }
        return false
    }
    
    func checkUpdateMonth(lastSavedDateComps: DateComponents) -> Bool {
        if UtilUserDefaults().resetOfMonth && self.checkChangeOfDate(lastSavedDateComps: lastSavedDateComps) {
            return true
        }
        return false
    }
    
    private func fetchMonthUsages(context: NSManagedObjectContext, initKey: String) -> [CurrentMonthNetworkUsage]? {
        return fetchDatabase(context: context, entityName: "CurrentMonthNetworkUsage", initKey: initKey) as? [CurrentMonthNetworkUsage]
    }
    
    private func fetchDayUsages(context: NSManagedObjectContext, initKey: String) -> [DayNetworkUsage]? {
        return fetchDatabase(context: context, entityName: "DayNetworkUsage", initKey: initKey) as? [DayNetworkUsage]
    }
    
    private func fetchDatabase(context: NSManagedObjectContext, entityName: String, initKey: String) -> [AnyObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptors = [NSSortDescriptor(key: initKey, ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            return nil
        }
    }
    
    func updateChartMonthManagedObj(usageData: DUCNetworkInterFace, managedObjectContext context: NSManagedObjectContext) -> DayNetworkUsage {
        let managedObject = self.getChartManagedObj(updateData: usageData, context: context)
        do {
            try managedObject.managedObjectContext!.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return managedObject
    }
    
    func getArrayFromChartObj(target: DayNetworkUsage) -> [AnyObject] {
        let wifiSend = target.wifi_sent
        let wifiReceived = target.wifi_received
        let wwanSend = target.wwan_sent
        let wwanReceived = target.wwan_received
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = DATE_FORMAT_FOR_CSV
        let dateStr = df.string(from: target.saved_date! as Date)
        return [wifiSend!, wifiReceived!, wwanSend!, wwanReceived!, dateStr as AnyObject]
    }
    
    func deleteEntityData(entityName: String, managedObjectContext context: NSManagedObjectContext) {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>()
        deleteRequest.entity = (NSEntityDescription.entity(forEntityName: entityName, in: context))
        deleteRequest.includesPropertyValues = true
        
        do {
            let results = try context.fetch(deleteRequest)
            for data in results as! [NSManagedObject] {
                context.delete(data)
            }
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func getManagedObject(updateData: DUCNetworkInterFace, target: CurrentMonthNetworkUsage, targetIndex: DataIndex) -> CurrentMonthNetworkUsage {
        let managedObject = target
        let timeinterval = ProcessInfo.processInfo.systemUptime
        let date = NSDate()
        if targetIndex.rawValue != Int(target.index!.intValue) {
            print("targetIndex error... targetIndex =\(targetIndex), target.index = \(target.index!.intValue)")
        }
        managedObject.index = NSNumber(value: targetIndex.rawValue)
        managedObject.last_boot_time = NSNumber(value: timeinterval)
        managedObject.last_save_time = date
        managedObject.wifi_sent = NSNumber(value: updateData.wifiSend)
        managedObject.wifi_received = NSNumber(value: updateData.wifiReceived)
        managedObject.wwan_sent = NSNumber(value: updateData.wwanSend)
        managedObject.wwan_received = NSNumber(value: updateData.wwanReceived)
        
        #if ENABLE_SWIFT_LOG
            print(managedObject.debugDescription)
        #endif//ENABLE_SWIFT_LOG
        
        return managedObject
    }
    
    func checkChangeOfDate(lastSavedDateComps: DateComponents) -> Bool {
        let date = Date()
        let dateComps = self.getDateComponents(date: date)
        let resetOfDay = Int(UtilUserDefaults().resetOfDay)
        
        switch resetOfDay {
        case 0, 1:
            /*この0ケースは存在しないと思うが一応デフォルトとして1と同じルートを通す*/
            if dateComps.month != lastSavedDateComps.month {
                return true
            }
                   
        case 29, 30, 31:
            /* 29〜31日の条件(月によって有無が変わる日にち) */
            if dateComps.day != lastSavedDateComps.day {
                if dateComps.month == 2 && dateComps.day! >= 28 {
                    return true
                    
                } else if dateComps.day == 30 && (dateComps.month == 4 || dateComps.month == 6 || dateComps.month == 9 || dateComps.month == 11) {
                    return true
                    
                } else if (dateComps.day == resetOfDay) {
                    return true
                }
            }
                   
        default:
            /* 2〜28日の条件(どの月にもある日にち) */
            if dateComps.day != lastSavedDateComps.day && dateComps.day == resetOfDay {
                return true
            }
                 
        }
        return false
    }
    
    func getChartManagedObj(updateData: DUCNetworkInterFace, context: NSManagedObjectContext) -> DayNetworkUsage {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: "DayNetworkUsage", into: context) as! DayNetworkUsage
        
        managedObject.saved_date = NSDate()
        managedObject.wifi_sent = NSNumber(value: updateData.wifiSend)
        managedObject.wifi_received = NSNumber(value: updateData.wifiReceived)
        managedObject.wwan_sent = NSNumber(value: updateData.wwanSend)
        managedObject.wwan_received = NSNumber(value: updateData.wwanReceived)
        
        #if ENABLE_SWIFT_LOG
            print(managedObject.debugDescription)
        #endif//ENABLE_SWIFT_LOG
        
        return managedObject
    }
    
    func fetchMonthNetworkUsage(context: NSManagedObjectContext) {
        let nowDataCount = DUCNetworkInterFace.getDataCounters()
        let formatDataCount = DUCNetworkInterFace()!
        
        var nextDataCount = formatDataCount
        var currentUsage: CurrentMonthNetworkUsage? = nil
        var offsetUsage: CurrentMonthNetworkUsage? = nil
        let cmnuArray: [AnyObject]? = fetchMonthUsages(context: context, initKey: "index")
        if nil == cmnuArray || 0 == cmnuArray!.count {
            /*
             ここは初回で、前回端末起動からの使用量が取得されるのでcsv保存しない.
             */
            UtilUserDefaults().updateCoreData = true
            self.createNetworkUsageManagedObj(usageData: nowDataCount!, withManagedObj: context)
            dataUsageCount = nowDataCount
        } else {
            var isNeedCacheClear = true
            currentUsage = cmnuArray?[PacketUsageRecorder.DataIndex.current.rawValue] as? CurrentMonthNetworkUsage
            offsetUsage = cmnuArray?[PacketUsageRecorder.DataIndex.offset.rawValue] as? CurrentMonthNetworkUsage
            var lastSaved = self.getNetworkInterFaceFromCMNU(target: currentUsage!)
            var lastSavedOffset = self.getNetworkInterFaceFromCMNU(target: offsetUsage!)
            let last_boot_time = currentUsage!.last_boot_time!.doubleValue
            let lastDateComps = self.getDateComponents(date: currentUsage!.last_save_time! as Date)
            if self.checkUpdateMonth(lastSavedDateComps: lastDateComps) {
                lastSaved = formatDataCount
                self.deleteEntityData(entityName: "DayNetworkUsage", managedObjectContext: context)
                UtilUserDefaults().updateCoreData = true
                
                arrayUsageLastMonth = [AnyObject]()
                //arrayUsageLastMonth?.append(arrayUsageThisMonth!)
                arrayUsageLastMonth! += arrayUsageThisMonth!
                arrayUsageThisMonth = [AnyObject]()
                let queue = OperationQueue()
                queue.addOperation({
                    let csvHelper = DUCCsvHelper()
                    //先月分データをcsvに保存.
                    self.arrayUsageLastMonth = csvHelper.writeCsvFile(self.arrayUsageLastMonth!, withNewArray: nil, andMonth: Int32(FILE_INDEX_LAST_MONTH)) as [AnyObject]
                    OperationQueue.main.addOperation({
                        // (UIの更新はメインスレッドから行う必要がある)
                    })
                    
                })
                isNeedCacheClear = true
            }
            
            if self.checkBootTimeAndIfDataResult(last_boot_time: last_boot_time) {
                lastSavedOffset = formatDataCount
            }
            
            self.updateNetworkUsageManagedObj(cmnu: offsetUsage!, updateType: .refresh, updateTargetIndex: .offset, newUsageData: nowDataCount!, context: context)
            nextDataCount = UtilNetworkIF.addOffsetValueToUsageData(currentData: nowDataCount!, lastSavedData: lastSaved, offsetData: lastSavedOffset)
            self.updateNetworkUsageManagedObj(cmnu: currentUsage!, updateType: .refresh, updateTargetIndex: .current, newUsageData: nextDataCount, context: context)
            self.updateChartThisMonth(beforeDataCounts: lastSaved, newDataCounts: nextDataCount, context: context)
            lastSavedUsageCount = lastSaved
            dataUsageCount = nextDataCount
            if isNeedCacheClear {
                DUCCsvHelper().removeCsvFile()
            }
        }
    }
    
    func getUsageResultFromCSV(chartDisp2Month: Bool) -> [DUCNetworkInterFace] {
        let csvNSArrays = DUCCsvHelper.getUsageResult(fromCsv: self.arrayUsageThisMonth, andLastMonth: (chartDisp2Month ? self.arrayUsageLastMonth : [Any]())) as NSArray
        let swiftNSArray: [NSArray] = csvNSArrays.compactMap({ $0 as? NSArray })
        let packetUsages = swiftNSArray.map { (nsArray) -> DUCNetworkInterFace in
            DUCNetworkInterFace(
                wifiSend: convertCsvValue(nsArray: nsArray, index: IFA_DATA_WIFI_SEND),
                wifiReceived: convertCsvValue(nsArray: nsArray, index: IFA_DATA_WIFI_RECEIVED),
                wwanSend: convertCsvValue(nsArray: nsArray, index: IFA_DATA_WWAN_SEND),
                wwanReceived: convertCsvValue(nsArray: nsArray, index: IFA_DATA_WWAN_RECEIVED),
                dateStr: nsArray[IFA_DATA_GET_DATE] as? String)
        }

        return packetUsages
    }
    
    private func convertCsvValue(nsArray: NSArray, index: Int) -> Int64 {
        guard let value = nsArray[index] as? NSNumber else { return Int64(0) }
        return value.int64Value
    }
    
    func updateChartThisMonth(beforeDataCounts: DUCNetworkInterFace, newDataCounts: DUCNetworkInterFace, context: NSManagedObjectContext) {
        let newRecord = self.getNextRecord(beforeDataCount: beforeDataCounts, newDataCount: newDataCounts)
        let obj = self.updateChartMonthManagedObj(usageData: newRecord, managedObjectContext: context)
        
        // TODO:
        //
        // Storyboardの変更を行う場合（4インチ以下のデバイス）にはdidFinishLaunchingWithOptionsを
        // 経由する前にここに到達するためarrayUsageThisMonthがnilとなることからunwrapだとcrashする...
        //
        arrayUsageThisMonth?.append(self.getArrayFromChartObj(target: obj) as AnyObject)
        /* これではダメ -> -> -> *///arrayUsageThisMonth!.append(self.cmnuManagedObj!.getArrayFromChartObj(obj))
    }
    
    func getNetworkUsageArrayData(context: NSManagedObjectContext) {
        let csvHelper = DUCCsvHelper()
        if (nil == arrayUsageThisMonth || 0 == arrayUsageThisMonth!.count) {
            arrayUsageThisMonth = csvHelper.readCsvFile(Int32(FILE_INDEX_THIS_MONTH)) as [AnyObject]
            
            if let dayNetworkUsageObj = fetchDayUsages(context: context, initKey: "saved_date") {
                for obj in dayNetworkUsageObj {
                    let array = self.getArrayFromChartObj(target: obj)
                    arrayUsageThisMonth!.append(array as AnyObject)
                }
            }
        }
        
        if (nil == arrayUsageLastMonth || 0 == arrayUsageLastMonth!.count) {
            arrayUsageLastMonth = csvHelper.readCsvFile(Int32(FILE_INDEX_LAST_MONTH)) as [AnyObject]
        }
    }
    
    func checkRecentLimitUsage() {
        if UtilUserDefaults().usageNotificationSetting {
            let usageArrayCsv = self.getUsageResultFromCSV(chartDisp2Month: true)
            let utilNotification = UtilLocalNotification()
            if (LIMIT_RECENT_USAGE < self.getRecentUsageValues(recentArray: usageArrayCsv)
                && utilNotification.isNeedRecentUsageNotification()) {
                utilNotification.setAlertRecentUsageNotification()
            }
        }
    }
    
    func getRecentUsageValues(recentArray: [DUCNetworkInterFace]) -> Int64 {
        var recentUsageValue = Int64(0)
        var dayCount: Int = 1
        
        let reverseArray = recentArray.reversed()
        //var reverseArray = recentArray.reverseObjectEnumerator().allObjects
        for day in reverseArray {
            recentUsageValue += Int64(UtilNetworkIF.getUsageValue(networkIf: day))
            if dayCount == 3 {
                break
            }
            dayCount += 1
        }
        
        return recentUsageValue
    }
        
    enum DataIndex: Int, CaseIterable {
        case current = 0,
        offset
    }
    
    enum UpdateType : Int, CaseIterable {
        case new = 0,
        refresh
    }
}
