//
//  UtilManagedObject.swift
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
//import DJKUtilities

class UtilManagedObject: NSObject {
    
    let DUC_PRODUCT_ID_UNLOCK_ALL_AD = "jp.co.JchanKchan.DataUsageCat.unlock_all_ad"
    let LIMIT_RECENT_USAGE = Int64(700000000)//((1000000000LL - 300000000LL))
    var arrayUsageLastMonth: [AnyObject]?
    var arrayUsageThisMonth: [AnyObject]?
    var dataUsageCount: DUCNetworkInterFace?
    var lastSavedUsageCount: DUCNetworkInterFace?

    func updateNetworkUsageManagedObj(cmnu: CurrentMonthNetworkUsage, updateType: UpdateType, updateTargetIndex: DataIndex, newUsageData: DUCNetworkInterFace, context: NSManagedObjectContext) {
        
        if UpdateType.NEW != updateType {
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
        self.updateNetworkUsageManagedObj(cmnu: objCurrent, updateType: UpdateType.NEW, updateTargetIndex: DataIndex.CURRENT, newUsageData: usageData, context: context)
        
        let objOffset = NSEntityDescription.insertNewObject(forEntityName: "CurrentMonthNetworkUsage", into: context) as! CurrentMonthNetworkUsage
        self.updateNetworkUsageManagedObj(cmnu: objOffset, updateType: UpdateType.NEW, updateTargetIndex: DataIndex.OFFSET, newUsageData: usageData, context: context)
    }
    
    func getNetworkInterFaceFromCMNU(target: CurrentMonthNetworkUsage) -> DUCNetworkInterFace {
        let fallbackValue = NSNumber(value: 0)
        let wifiSend = (target.wifi_sent != nil ? target.wifi_sent : fallbackValue)
        let wifiReceived = (target.wifi_received != nil ? target.wifi_received : fallbackValue)
        let wwanSend = (target.wwan_sent != nil ? target.wwan_sent : fallbackValue)
        let wwanReceived = (target.wwan_received != nil ? target.wwan_received : fallbackValue)
        return DUCNetworkInterFace.generateNetWork(from: [wifiSend!, wifiReceived!, wwanSend!, wwanReceived!])
    }
    
    func getDateComponents(date: Date) -> DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }
    
    func getNextRecord(beforeDataCount: DUCNetworkInterFace, newDataCount: DUCNetworkInterFace) -> DUCNetworkInterFace {
        let wifiSend = newDataCount.wifiSend - beforeDataCount.wifiSend
        let wifiReceived = newDataCount.wifiReceived - beforeDataCount.wifiReceived
        let wwanSend = newDataCount.wwanSend - beforeDataCount.wwanSend
        let wwanReceived = newDataCount.wwanReceived - beforeDataCount.wwanReceived
        
        return DUCNetworkInterFace.generateNetWork(from: [NSNumber(value: wifiSend), NSNumber(value: wifiReceived), NSNumber(value: wwanSend), NSNumber(value: wwanReceived)])
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
    
    func getResultsOfFetchRequest(context: NSManagedObjectContext, withEntityName entityName: String, andKey initKey: String) -> [AnyObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptors = [NSSortDescriptor(key: initKey, ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
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
        let formatDataCount = DUCNetworkInterFace()
        var nextDataCount = formatDataCount
        //var cmnuArray: [AnyObject]? = nil
        var cmnuCurrent: CurrentMonthNetworkUsage? = nil
        var cmnuOffset: CurrentMonthNetworkUsage? = nil
        let cmnuArray: [AnyObject]? = self.getResultsOfFetchRequest(context: context, withEntityName: "CurrentMonthNetworkUsage", andKey: "index")
        if nil == cmnuArray || 0 == cmnuArray!.count {
            /*
             ここは初回で、前回端末起動からの使用量が取得されるのでcsv保存しない.
             */
            UtilUserDefaults().updateCoreData = true
            self.createNetworkUsageManagedObj(usageData: nowDataCount!, withManagedObj: context)
            dataUsageCount = nowDataCount
        } else {
            var isNeedCacheClear = true
            cmnuCurrent = cmnuArray?[UtilManagedObject.DataIndex.CURRENT.rawValue] as? CurrentMonthNetworkUsage
            cmnuOffset = cmnuArray?[UtilManagedObject.DataIndex.OFFSET.rawValue] as? CurrentMonthNetworkUsage
            var lastSaved = self.getNetworkInterFaceFromCMNU(target: cmnuCurrent!)
            var lastSavedOffset = self.getNetworkInterFaceFromCMNU(target: cmnuOffset!)
            let last_boot_time = cmnuCurrent!.last_boot_time!.doubleValue
            let lastDateComps = self.getDateComponents(date: cmnuCurrent!.last_save_time! as Date)
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
            
            self.updateNetworkUsageManagedObj(cmnu: cmnuOffset!, updateType: .REFLESH, updateTargetIndex: .OFFSET, newUsageData: nowDataCount!, context: context)
            nextDataCount = UtilNetworkIF.addOffsetValueToUsageData(currentData: nowDataCount!, lastSavedData: lastSaved, offsetData: lastSavedOffset)
            self.updateNetworkUsageManagedObj(cmnu: cmnuCurrent!, updateType: .REFLESH, updateTargetIndex: .CURRENT, newUsageData: nextDataCount, context: context)
            self.updateChartThisMonth(beforeDataCounts: lastSaved, newDataCounts: nextDataCount, context: context)
            lastSavedUsageCount = lastSaved
            dataUsageCount = nextDataCount
            if isNeedCacheClear {
                DUCCsvHelper().removeCsvFile()
            }
        }
    }
    
    func getUsageResultFromCSV(chartDisp2Month: Bool) -> [Any] {
        let ret: [Any]
        if chartDisp2Month {
            ret = DUCCsvHelper.getUsageResult(fromCsv: self.arrayUsageThisMonth, andLastMonth: self.arrayUsageLastMonth)
        } else {
            ret = DUCCsvHelper.getUsageResult(fromCsv: self.arrayUsageThisMonth, andLastMonth: [Any]())
        }
        
        return ret
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
            //if nil == cmnuManagedObj {
            //cmnuManagedObj = DUCUtilManagedObject()
            //}
            
            let dayNetworkUsageObj = self.getResultsOfFetchRequest(context: context, withEntityName: "DayNetworkUsage", andKey: "saved_date") //as! [AnyObject]
            for obj in dayNetworkUsageObj {
                let array: [AnyObject] = self.getArrayFromChartObj(target: obj as! DayNetworkUsage)
                //arrayUsageThisMonth! += array
                arrayUsageThisMonth!.append(array as AnyObject)
                //arrayUsageThisMonth!.addObject(array)
            }
        }
        
        if (nil == arrayUsageLastMonth || 0 == arrayUsageLastMonth!.count) {
            arrayUsageLastMonth = csvHelper.readCsvFile(Int32(FILE_INDEX_LAST_MONTH)) as [AnyObject]
            //arrayUsageLastMonth = csvHelper.readCsvFile(FILE_INDEX_LAST_MONTH)
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
    
    func getRecentUsageValues(recentArray: [Any]) -> Int64 {
        var recentUsageValue = Int64(0)
        var dayCount: Int = 1
        
        let reverseArray = recentArray.reversed()
        //var reverseArray = recentArray.reverseObjectEnumerator().allObjects
        for day in reverseArray {
            recentUsageValue += Int64(UtilNetworkIF.getUsageValue(networkIf: DUCNetworkInterFace.generateNetWork(from: day as! [AnyObject])))
            if dayCount == 3 {
                break
            }
            dayCount += 1
        }
        
        return recentUsageValue
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "jp.co.jchankchan.TemplateCoreData" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DataUsageCat", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("DataUsageCat.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let migrateOptions: Dictionary<String, Bool> = [NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption :true];
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: migrateOptions)
        } catch {
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        if #available(iOS 10.0, *) {
            if UtilUserDefaults().updateCoreData {
                return self.persistentContainer.viewContext
            }
        }
        return self.legacyManagedObjectContext
    }()
    
    lazy var legacyManagedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DataUsageCat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    enum  DataIndex: Int {
        case CURRENT = 0,
        OFFSET,
        MAX
    }
    
    enum UpdateType : Int {
        case NEW = 0,
        REFLESH,
        MAX
    }
}
