//
//  SettingsViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/05.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDidFinish(controller: SettingsViewController)
}

class SettingsViewController: HelpingMonetizeViewController,
    UITableViewDelegate, UITableViewDataSource
{

    var isShowPickerDate: Bool = false
    weak var delegate: SettingsViewControllerDelegate?

    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var barButtonDone: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("app_settings", comment:"")
        let nib = UINib(nibName: "PickerViewCell", bundle: nil)
        self.settingsTableView.register(nib, forCellReuseIdentifier: "PickerViewCell")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //TODO -> self.view.addSubview(nendBannerView)
            } else {
                addAdMobBannerView(unitId: KeyIdAdMob.BANNER_PHONE)
                                            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.settingsTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ("DetailSettingViewController") {
            let indexPath = self.settingsTableView.indexPath(for: sender as! UITableViewCell)
            switch indexPath!.section {
            case SettingBasicSection.BASIC.rawValue:
                self.prepareDetailSettingViewController(segue: segue, withIndexPath: indexPath!)
                
            case SettingBasicSection.ADVANCE.rawValue:
                self.prepareDetailSettingViewController(segue: segue, withIndexPath: indexPath!)
                
            default:
                break
            }
        }
    }

    func prepareDetailSettingViewController(segue: UIStoryboardSegue, withIndexPath indexPath: IndexPath) {
        let controller = segue.destination as! DetailSettingViewController
        switch indexPath.section {
        case SettingBasicSection.BASIC.rawValue:
            switch indexPath.row {
            case SettingBasicRow.RESET_MONTH.rawValue:
                controller.settingType = DetailSettingViewController.DetailSettingType.DATE.rawValue
                
            case SettingBasicRow.LIMIT_VALUE.rawValue:
                controller.settingType = DetailSettingViewController.DetailSettingType.LIMIT.rawValue
                
            default:
                break
            }
            
        case SettingBasicSection.ADVANCE.rawValue:
            switch indexPath.row {
            case SettingAdvanceRow.NOTIFICATION.rawValue:
                controller.settingType = DetailSettingViewController.DetailSettingType.NOTIFICATION.rawValue
                
            default:
                break
            }
            
        default:
            break
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingBasicSection.MAX_SECTION.rawValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingBasicSection(rawValue: section)! {
        case .BASIC:
            return SettingBasicRow.MAX_ROW.rawValue
        case .ADVANCE:
            return SettingAdvanceRow.MAX_ROW.rawValue
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SettingBasicSection.BASIC.rawValue && indexPath.row == SettingBasicRow.LIMIT_VALUE.rawValue {
            if self.isShowPickerDate {
                return PickerViewCell.reuseCellDetailSettingDate(tableView: tableView, cellForRowAtIndexPath: indexPath, detailPickerType: PickerViewCell.PickerType.LIMIT_USAGE_VALUE)
            }
        }
        return reuseSettingtableView(tableView: tableView, cellForRowAtIndexPath: indexPath)
    }

    private func reuseSettingtableView(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == SettingBasicSection.BASIC.rawValue && indexPath.row == SettingBasicRow.LIMIT_VALUE.rawValue {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "CellSettings", for: indexPath )
        }
        
        let preference = UserPreferences.shared
        switch indexPath.section {
        case SettingBasicSection.BASIC.rawValue:
            switch indexPath.row {
            case SettingBasicRow.LIMIT_VALUE.rawValue:
                cell.textLabel!.text = NSLocalizedString("limit_usage_value", comment:"")
                let limitValue = preference.limitUsageValue
                cell.detailTextLabel!.text = "\(limitValue) GB"
                
            case SettingBasicRow.RESET_MONTH.rawValue:
                cell.textLabel!.text = NSLocalizedString("reset_every_month", comment:"")
                
                if preference.resetOfMonth {
                    cell.detailTextLabel!.text = "ON"
                } else {
                    cell.detailTextLabel!.text = "OFF"
                }
            default:
                break
            }
            
        case SettingBasicSection.ADVANCE.rawValue:
            switch indexPath.row {
            case SettingAdvanceRow.NOTIFICATION.rawValue:
                cell.textLabel!.text = NSLocalizedString("notification", comment:"")
                
                if preference.usageNotificationSetting {
                    cell.detailTextLabel!.text = "ON"
                } else {
                    cell.detailTextLabel!.text = "OFF"
                }
            default:
                break
            }
            
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SettingBasicSection.BASIC.rawValue:
            switch indexPath.row {
            case SettingBasicRow.LIMIT_VALUE.rawValue:
                self.isShowPickerDate = !self.isShowPickerDate
                UIView.animate(withDuration: 0.4, animations: {
                    let indexPath = IndexPath.init(row: SettingBasicRow.LIMIT_VALUE.rawValue, section: SettingBasicSection.BASIC.rawValue)
                    self.settingsTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                })
                
            default:
                break
            }
            
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SettingBasicSection.BASIC.rawValue:
            switch indexPath.row {
            case SettingBasicRow.LIMIT_VALUE.rawValue:
                if self.isShowPickerDate {
                    return CGFloat(PickerViewCell().PICKERVIEWCELL_ROW_HEIGHT)
                }
            default:
                break
            }
            
        default:
            break
        }

        return tableView.rowHeight
    }

    @IBAction func done() {
        self.delegate?.settingsViewControllerDidFinish(controller: self)
        self.dismiss(animated: true, completion: nil)
    }

    enum SettingBasicRow : Int {
        case LIMIT_VALUE = 0,
        RESET_MONTH,
        MAX_ROW
    }
    
    enum SettingBasicSection : Int {
        case BASIC = 0,
        ADVANCE,
        MAX_SECTION
    };
    
    enum SettingAdvanceRow : Int {
        case NOTIFICATION = 0,
        MAX_ROW
    };
    
    enum SettingPremiumRow : Int {
        case UNLOCK_AD = 0,
        MAX_ROW_SETTINGS_PREMIUM
    };
}
