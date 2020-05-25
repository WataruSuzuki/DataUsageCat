//
//  DebugSettingViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/11/21.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit

class DebugSettingViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DebugMenuSection.MAX.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DebugMenuSection(rawValue: section)! {
        case .pushMode:
            return DebugPushModeRow.MAX.rawValue
        case .manual_exe:
            return ManualExeRow.MAX.rawValue
            
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugSettingCell", for: indexPath)

        // Configure the cell...
        switch DebugMenuSection(rawValue: indexPath.section)! {
        case .pushMode:
            if let menu = DebugPushModeRow(rawValue: indexPath.row) {
                cell.textLabel?.text = menu.toString()
                cell.accessoryView = menu.handleSwitch()
            }
            
        case .manual_exe:
            cell.textLabel?.numberOfLines = 0
            let utilNotification = UtilLocalNotification()
            switch ManualExeRow(rawValue: indexPath.row)! {
            case .catStartWorking:
                cell.textLabel?.text = utilNotification.catVeryDelighting + utilNotification.bodyCatStartWorking
            case .catSilentIsWorking:
                cell.textLabel?.text = utilNotification.catSmiling + utilNotification.bodySilentIsWorking
            case .catRestartDataMonitoring:
                cell.textLabel?.text = NSLocalizedString("title_not_work_recently", comment: "")
                
            default:
                break
            }
            
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch DebugMenuSection(rawValue: indexPath.section)! {
        case .manual_exe:
            switch ManualExeRow(rawValue: indexPath.row)! {
            case .catStartWorking:
                UtilNCMB().registPollingPushScheduleFromWataru()
            case .catSilentIsWorking:
                UtilCloudKit().updateAllDeviceRecordObject()
            case .catRestartDataMonitoring:
                if UserPreferences.shared.silentNotificationSetting {
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    UtilLocalNotification().catRestartDataMonitoring()
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    @objc func setSilentNotificationSetting(sw: UISwitch) {
        UserPreferences.shared.silentNotificationSetting = sw.isOn
    }
    
    @objc func setDebugCloudKitSilentPush(sw: UISwitch) {
        UserPreferences.shared.debugCloudKitSilentPush = sw.isOn
    }
    
    @objc func setDebugLegacySubscription(sw: UISwitch) {
        UtilCloudKit().deleteAllPublicSubscription()
        UserPreferences.shared.debugLegacySubscription = sw.isOn
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    enum ManualExeRow: Int {
        case catStartWorking = 0,
        catSilentIsWorking,
        catRestartDataMonitoring,
        MAX
        
        func toString() -> String {
            return String(describing: self)
        }
    }

    enum DebugMenuSection: Int {
        case pushMode = 0,
        manual_exe,
        MAX
    }
    
    enum DebugPushModeRow: Int {
        case silentNotificationSetting = 0,
        debugCloudKitSilentPush,
        debugLegacySubscription,
        MAX
        
        func toString() -> String {
            return String(describing: self)
        }
        
        func handleSwitch() -> UISwitch {
            let myUISwitch = UISwitch()
            
            let preference = UserPreferences.shared
            switch self {
            case .silentNotificationSetting:
                myUISwitch.isOn = preference.silentNotificationSetting
                myUISwitch.addTarget(self, action: #selector(DebugSettingViewController.setSilentNotificationSetting(sw:)), for: .valueChanged)
                
            case .debugCloudKitSilentPush:
                myUISwitch.isOn = preference.debugCloudKitSilentPush
                myUISwitch.addTarget(self, action: #selector(DebugSettingViewController.setDebugCloudKitSilentPush(sw:)), for: .valueChanged)
                
            case .debugLegacySubscription:
                myUISwitch.isOn = preference.debugLegacySubscription
                myUISwitch.addTarget(self, action: #selector(DebugSettingViewController.setDebugLegacySubscription(sw:)), for: .valueChanged)
                
            default:
                break
            }
            
            return myUISwitch
        }
    }
}
