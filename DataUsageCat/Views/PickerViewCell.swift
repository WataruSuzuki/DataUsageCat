//
//  PickerViewCell.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/06/02.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

import UIKit

class PickerViewCell: UITableViewCell,
    UIPickerViewDataSource,
    UIPickerViewDelegate
{
    
    let PICKERVIEWCELL_ROW_HEIGHT = 256
    
    private var typeOfComponents: PickerType!
    private var numberOfComponents: PickerComp!
    
    @IBOutlet weak var addedPickerView: UIPickerView!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setPickerViewType(type: PickerType) {
        let duc_ud = UtilUserDefaults()
        self.typeOfComponents = type
        switch self.typeOfComponents! {
        case .LIMIT_DATE:
            labelTitle.text = NSLocalizedString("reset_date", comment:"")
            addedPickerView.selectRow(duc_ud.resetOfDay - 1, inComponent: 0, animated: false)
            
        case .LIMIT_USAGE_VALUE:
            labelTitle.text = NSLocalizedString("limit_usage_value", comment:"")
            var limitValue = Int(duc_ud.limitUsageValue)
            var digit = Int(self.getDigitOffsetValue())
            for component in 0 ..< PickerComp.DIGIT_UNIT.rawValue {
                addedPickerView.selectRow((limitValue / digit), inComponent: component, animated: false)
                limitValue = limitValue % digit
                digit /= 10
            }
                   
        default:
            break
        }
    }
    
    func reloadAllComponents(type: PickerType) {
        self.typeOfComponents = type
        switch self.typeOfComponents! {
        case .LIMIT_DATE:
            self.numberOfComponents = .DIGIT_1
                   
        case .LIMIT_USAGE_VALUE:
            self.numberOfComponents = .MAX
                   
        default:
            break
        }
        self.addedPickerView.reloadAllComponents()
    }
    
    func getDigitOffsetValue() -> Int {
        var digit = 1
        for _ in 1 ..< PickerComp.DIGIT_UNIT.rawValue {
            digit *= 10
        }
        return digit
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if nil != self.numberOfComponents {
            return self.numberOfComponents.rawValue
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch self.typeOfComponents! {
        case .LIMIT_DATE:
            return 31
                   
        case .LIMIT_USAGE_VALUE:
            if component == PickerComp.DIGIT_UNIT.rawValue {
                return 1
            }
            return 10
            
        default:
            break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch self.typeOfComponents! {
        case .LIMIT_DATE:
            return "\(row + 1)"
                   
        case .LIMIT_USAGE_VALUE:
            if component == PickerComp.DIGIT_UNIT.rawValue {
                return "GB"
            }
                   
        default:
            break
        }
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(50.0)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch self.typeOfComponents! {
        case .LIMIT_DATE:
            self.pickerViewResetOfDay(pickerView: pickerView, didSelectRow: row, inComponent: component)
                   
        case .LIMIT_USAGE_VALUE:
            self.pickerViewLimitValue(pickerView: pickerView, didSelectRow: row, inComponent: component)
                   
        default:
            break
        }
    }
    
    func pickerViewResetOfDay(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UtilUserDefaults().resetOfDay = (row + 1)
    }
    
    func pickerViewLimitValue(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if 0 == pickerView.selectedRow(inComponent: PickerComp.DIGIT_10.rawValue) && 0 == pickerView.selectedRow(inComponent: PickerComp.DIGIT_1.rawValue) {
            pickerView.selectRow(1, inComponent: PickerComp.DIGIT_1.rawValue, animated: true)
        }
        self.setUserDefaultLimitUsageValue()
    }
    
    func setUserDefaultLimitUsageValue() {
        var nextValue = 0
        var digit = self.getDigitOffsetValue()
        for i in 0 ..< PickerComp.DIGIT_UNIT.rawValue {
            nextValue += addedPickerView.selectedRow(inComponent: i) * digit
            digit /= 10
        }
        if 0 > nextValue {
            nextValue = 7
        }
        UtilUserDefaults().limitUsageValue = Float(nextValue)
    }
    
    class func reuseCellDetailSettingDate(tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, detailPickerType pickerType: PickerType) -> UITableViewCell {
        let pickerCell = tableView.dequeueReusableCell(withIdentifier: "PickerViewCell", for: indexPath) as! PickerViewCell
        pickerCell.reloadAllComponents(type: pickerType)
        pickerCell.setPickerViewType(type: pickerType)
        
        return pickerCell
    }
    
    enum PickerType : Int {
        case LIMIT_DATE = 0,
        LIMIT_USAGE_VALUE,
        MAX
    }
    
    enum PickerComp : Int {
        case DIGIT_10 = 0,
        DIGIT_1,
        DIGIT_UNIT,
        MAX
    }
    
}
