//
//  SettingsViewController.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2015/07/05.
//  Copyright © 2015年 Wataru Suzuki. All rights reserved.
//

import UIKit

class DetailSettingViewController: HelpingMonetizeViewController,
    UITableViewDelegate, UITableViewDataSource
{
    var settingType: Int = DetailSettingType.DATE.rawValue
    var secretButtonTappedCount = 0

    //@IBOutlet var iAd_BannerView: ADBannerView!
    @IBOutlet weak var detailSettingsTableView: UITableView!
    @IBOutlet weak var buttonSecretMenu: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PickerViewCell", bundle: nil)
        self.detailSettingsTableView.register(nib, forCellReuseIdentifier: "PickerViewCell")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.isUnlockAd {
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                //TODO -> self.view.addSubview(nendBannerView!)
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
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let ret: Int
        switch settingType {
        case DetailSettingType.DATE.rawValue:
            ret = SectionTypeOther.MAX_NUM_DETAIL_DATE.rawValue
            
        case DetailSettingType.NOTIFICATION.rawValue:
            ret = SectionTypeSwitch.MAX_NUM_COMMON_SECTION.rawValue
            
        default:
            ret = 0
        }

        return ret
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //今のところsectionで分けているので1で固定.
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "CellDetailSettings"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: CellIdentifier)
        if indexPath.section == SectionTypeSwitch.DETAIL_SWITCH.rawValue {
            let switchOnOff = UISwitch(frame: .zero)
            switchOnOff.isOn = self.getSwitchSettingValue()
            switchOnOff.addTarget(self, action: #selector(DetailSettingViewController.changeSwitch(sw:)), for: .valueChanged)
            cell.textLabel!.text = self.getTextLabelStr()
            cell.accessoryView = switchOnOff
        } else {
            switch settingType {
            case DetailSettingType.DATE.rawValue:
                switch indexPath.section {
                case SectionTypeOther.DETAIL_PICK_DATE.rawValue:
                    return PickerViewCell.reuseCellDetailSettingDate(tableView: tableView, cellForRowAtIndexPath: indexPath, detailPickerType: PickerViewCell.PickerType.LIMIT_DATE)
                    
                case SectionTypeOther.DETAIL_RESET_CHART.rawValue:
                    let switchOnOff = UISwitch(frame: .zero)
                    switchOnOff.isOn = UtilUserDefaults().chartDisp2Month
                    switchOnOff.addTarget(self, action: #selector(DetailSettingViewController.changeSwitchResetChart(sw:)), for: .valueChanged)
                    cell.textLabel!.text = NSLocalizedString("reset_chart_display", comment:"")
                    cell.accessoryView = switchOnOff
                    
                default:
                    break
                }

            default:
                break
            }
        }
        return cell
    }

    func getSwitchSettingValue() -> Bool {
        var ret: Bool = false
        let duc_ud = UtilUserDefaults()
        switch settingType {
        case DetailSettingType.DATE.rawValue:
            ret = duc_ud.resetOfMonth
            
        case DetailSettingType.NOTIFICATION.rawValue:
            ret = duc_ud.usageNotificationSetting
            
        default:
            break
        }

        return ret
    }

    func getTextLabelStr() -> String {
        switch settingType {
        case DetailSettingType.DATE.rawValue:
            return NSLocalizedString("reset_every_month", comment:"")
            
        case DetailSettingType.NOTIFICATION.rawValue:
            return NSLocalizedString("notification", comment:"")
            
        default:
            break
        }

        return ""
    }

    @objc func changeSwitchResetChart(sw: UISwitch) {
        let duc_ud = UtilUserDefaults()
        duc_ud.chartDisp2Month = sw.isOn
    }

    @objc func changeSwitch(sw: UISwitch) {
        let duc_ud = UtilUserDefaults()
        switch settingType {
        case DetailSettingType.DATE.rawValue:
            duc_ud.resetOfMonth = sw.isOn
            
        case DetailSettingType.NOTIFICATION.rawValue:
            duc_ud.usageNotificationSetting = sw.isOn
            
        default:
            break
        }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionTypeOther.DETAIL_PICK_DATE.rawValue {
            return CGFloat(PickerViewCell().PICKERVIEWCELL_ROW_HEIGHT)
        }

        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch settingType {
        case DetailSettingType.NOTIFICATION.rawValue:
            if section == SectionTypeSwitch.DETAIL_SWITCH.rawValue {
                return NSLocalizedString("footer_setting_notification", comment:"")
            }
            
        case DetailSettingType.DATE.rawValue:
            if section == SectionTypeOther.DETAIL_RESET_CHART.rawValue {
                return NSLocalizedString("footer_setting_reset_chart", comment:"")
            }

        default:
            break
        }

        return ""
    }
    
    @IBAction func tapSecretButton(sender: Any) {
        secretButtonTappedCount += 1
        if 20 < secretButtonTappedCount {
            let title = "(=・∀・=)"
            let message = "パケ代にゃんこ！"
            let button = "ニャー！"
            
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: button, style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "DebugSettingViewController", sender: self)
            }))
            self.present(controller, animated: true, completion: nil)
            
            secretButtonTappedCount = -100
            
        }
    }
    
    enum DetailSettingType : Int {
        case DATE = 0,
        LIMIT,
        NOTIFICATION,
        MAX_NUM_DETAIL_SETTING
    }
    
    enum SectionTypeSwitch : Int {
        case DETAIL_SWITCH = 0,
        MAX_NUM_COMMON_SECTION
    }
    
    enum SectionTypeOther : Int {
        case DETAIL_PICK_DATE = 1,
        DETAIL_RESET_CHART,
        MAX_NUM_DETAIL_DATE
    };
}
