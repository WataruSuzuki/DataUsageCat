//
//  SettingsViewController.swift
//  DataUsageCat
//
//  Created by 鈴木 航 on 2015/07/05.
//  Copyright © 2015年 鈴木 航. All rights reserved.
//

/* Hello Swift, Goodbye Obj-C.
 * converted by 'objc2swift' https://github.com/yahoojapan/objc2swift
 * original source: ViewControllers/SettingsViewController.h, ViewControllers/SettingsViewController.m
 */
import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDidFinish(controller: SettingsViewController)
}

class SettingsViewController: DJKAdMobBaseViewController,
    UITableViewDelegate, UITableViewDataSource
{

    var isShowPickerDate: Bool = false
    var utilNADView: DJKUtilNendAd?
    var nendBannerView: NADView!
    weak var delegate: SettingsViewControllerDelegate?

    //@IBOutlet var iAd_BannerView: ADBannerView!
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
                utilNADView = delegate.utilNADView
                nendBannerView = utilNADView?.setupNendBannerView(self.view.frame, uiUserInterfaceIdiom: .phone, sizeType: SIZE_NEND_BANNER_320_50, apiKey: KeyIdAppBankSSP.KEY_BANNER_320_50, spotId: KeyIdAppBankSSP.ID_BANNER_320_50)
                
                self.view.addSubview(nendBannerView)
            } else {
                addAdMobBannerView(KeyIdAdMob.BANNER_PHONE)
                DJKViewUtils.setConstraintBottomView(admobBannerView, currentAndTo: self.view)
                DJKViewUtils.setConstraintCenterX(admobBannerView, currentView: self.view)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.settingsTableView.reloadData()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
        } else {
            utilNADView?.notifyBannerResume(nendBannerView)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        utilNADView?.notifyBannerPause()
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
        
        let duc_ud = UtilUserDefaults()
        switch indexPath.section {
        case SettingBasicSection.BASIC.rawValue:
            switch indexPath.row {
            case SettingBasicRow.LIMIT_VALUE.rawValue:
                cell.textLabel!.text = NSLocalizedString("limit_usage_value", comment:"")
                let limitValue = duc_ud.limitUsageValue
                cell.detailTextLabel!.text = "\(limitValue) GB"
                
            case SettingBasicRow.RESET_MONTH.rawValue:
                cell.textLabel!.text = NSLocalizedString("reset_every_month", comment:"")
                
                if duc_ud.resetOfMonth {
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
                
                if duc_ud.usageNotificationSetting {
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
                    self.settingsTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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
