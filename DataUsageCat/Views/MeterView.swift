//
//  MeterView.swift
//  DataUsageCat
//
//  Created by WataruSuzuki on 2020/03/28.
//  Copyright © 2020 WataruSuzuki. All rights reserved.
//

import UIKit

@IBDesignable
class MeterView: UIView {

    @IBOutlet weak var meterNeedleImage: UIImageView!
    @IBOutlet weak var buttonTopCatStatusImage: UIButton!
    @IBOutlet weak var imageMeterBackGround: UIImageView!
    @IBOutlet weak var buttonCurrentMonthValue: UIButton!
    @IBOutlet weak var titleMonthValueLabel: UILabel!
//    @IBOutlet weak var barButtonAboutThisApp: UIBarButtonItem!
//    @IBOutlet weak var barButtonSettings: UIBarButtonItem!
    @IBOutlet weak var segmentDataUsageType: UISegmentedControl!
    @IBOutlet weak var adConstraintView: UIView!
    @IBOutlet weak var meterNeedleButtonBgView: UIView!
    @IBOutlet weak var meterNeedleButton: UIButton!

    var dataUsageCount: DUCNetworkInterFace?
    var userDefaultLimit = Float(7.0)
    var needleAngle: Float = OFFSET_START_ANGLE
    var statusImageFilename: String = UsageProgessStats.GOOD.getStatusPartsName()
    var tapTopCatStatus: (() -> Void)?
    var tapCurrentMonth: (() -> Void)?
    var tapInfo: (() -> Void)?
    var tapJarashi: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiateView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiateView()
    }

    private func instantiateView() {
        let nib = Bundle(for: type(of: self)).loadNibNamed("MeterView", owner: self, options: nil)
        if let rootView = nib?.first as? UIView {
            self.addSubview(rootView)
            rootView.autoPinEdgesToSuperviewSafeArea()
        }
    }
    
    func setInitViewImage() {
        meterNeedleButton?.setTitle("", for: [])
        self.needleAngle = OFFSET_START_ANGLE
        
        buttonTopCatStatusImage.setBackgroundImage(UIImage(named: "cat_good"), for: [])
        meterNeedleImage.image = UIImage(named: "jarashi_good")
        let affine = (2 * .pi * Double(self.needleAngle) / 360.0 - 0.000001)
        self.meterNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.meterNeedleButtonBgView.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
        }
    }
    
    func setViewTitle() {
        titleMonthValueLabel?.text = SegmentType.USAGE.toString()
        segmentDataUsageType.setTitle(SegmentType.USAGE.toString(), forSegmentAt: SegmentType.USAGE.rawValue)
        segmentDataUsageType.setTitle(SegmentType.REMAIN.toString(), forSegmentAt: SegmentType.REMAIN.rawValue)
        segmentDataUsageType.setTitle(SegmentType.SAVE.toString(), forSegmentAt: SegmentType.SAVE.rawValue)
    }
    
    func setNeedlePosition() {
        let usermax = self.userDefaultLimit
        let savingUsageValue = PacketUsageConverter.get(dataUsage: dataUsageCount!, of: .wifi, unit: .giga)
        let usageValue = PacketUsageConverter.get(dataUsage: dataUsageCount!, of: .wwan, unit: .giga)
        self.startAnimationMeterNeedle(dataUsage: usageValue, DurationTime: TIME_DELAY_1SECOND)
        let num = NSNumber(value: usageValue)
        let delay = Double(TIME_DELAY_1SECOND) * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.updateTopUsageStatus(num: num)
        })
        self.setCurrentMonthValueLabelAndButton(usermax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }
    
    func setCurrentMonthValueLabelAndButton(usermax: Float, andWifiUsage savingUsageValue: Float, andCellularUsage usageValue: Float) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.setDataUsageValueText(index: SegmentType.USAGE.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
            self.setDataUsageValueText(index: SegmentType.REMAIN.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
            self.setDataUsageValueText(index: SegmentType.SAVE.rawValue, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
        }
        
        self.setDataUsageValueText(index: segmentDataUsageType.selectedSegmentIndex, andUserMax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }
    
    func setDataUsageValueText(index: Int, andUserMax usermax: Float, andWifiUsage savingUsageValue: Float, andCellularUsage usageValue: Float) {
        let segmentType = SegmentType(rawValue: index)
        let titleStr = (segmentType?.toString())!
        
        var remainValue: Float = (usermax - usageValue)
        if 0 > remainValue {
            remainValue = 0
        }
        
        titleMonthValueLabel?.text = titleStr
        switch index {
        case SegmentType.USAGE.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", usageValue), for: [])
            
        case SegmentType.REMAIN.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", remainValue), for: [])
            
        case SegmentType.SAVE.rawValue:
            buttonCurrentMonthValue.setTitle(String(format: "%.1f", savingUsageValue), for: [])
            
        default:
            break
        }
        buttonCurrentMonthValue.accessibilityIdentifier = "buttonCurrentMonthValue"
    }
    
    func startAnimationMeterNeedle(dataUsage: Float, DurationTime durationTime: Float) {
        let usermax = self.userDefaultLimit
        var angleValue: Float = (dataUsage - usermax / 2) * (ADJUST_ANGLE / (usermax / 2))
        if OFFSET_START_ANGLE > angleValue {
            angleValue = OFFSET_START_ANGLE
        } else if ADJUST_ANGLE < angleValue {
            angleValue = ADJUST_ANGLE
        } else {
            //do nothing
        }
        
        UIView.animate(withDuration: TimeInterval(durationTime), animations: { () -> Void in
            self.needleAngle = angleValue
            let affine = (2 * .pi * Double(self.needleAngle) / 360.0 - 0.000001)
            //let affine = (2*M_PI*Double(self.needleAngle)/360.0-0.000001)
            self.meterNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
            self.meterNeedleButtonBgView.transform = CGAffineTransform(rotationAngle: CGFloat(affine))
        })
    }
    
    func updateTopUsageStatus(num: NSNumber) {
        let usermax = self.userDefaultLimit
        let usageValue = num.floatValue
        
        if let progStatus = UsageProgessStats(rawValue: getUsageProgressStatus(usageValue: usageValue, withUserMax: usermax)) {
            statusImageFilename = (progStatus.getStatusPartsName())
            
            buttonTopCatStatusImage.setBackgroundImage(UIImage(named: statusImageFilename), for: [])
            meterNeedleImage.image = UIImage(named: progStatus.getJarashiName())
        }
    }
    
    func getUsageProgressStatus(usageValue: Float, withUserMax usermax: Float) -> Int {
        let ret: Int
        if usageValue > (usermax * 0.75) {
            ret = UsageProgessStats.DANGEROUS.rawValue
        } else if usageValue > (usermax * 0.5) {
            ret = UsageProgessStats.CAUTION.rawValue
        } else if usageValue > (usermax * 0.25) {
            ret = UsageProgessStats.FINE.rawValue
        } else {
            ret = UsageProgessStats.GOOD.rawValue
        }
        
        return ret
    }
    
    @IBAction
    func tapTopCatStatus(sender: UIButton) {
        tapTopCatStatus?()
    }
    
    @IBAction
    func tapCurrentMonth(sender: UIButton) {
        tapCurrentMonth?()
    }
    
    @IBAction
    func togglePopover(sender: AnyObject) {
        tapInfo?()
    }
    
    @IBAction
    func tapJarashi(sender: UIButton) {
        tapJarashi?()
    }
    
    @IBAction func tapSegmentDataUsageType(sender: AnyObject) {
        let usermax = self.userDefaultLimit
        let savingUsageValue = PacketUsageConverter.get(dataUsage: dataUsageCount!, of: .wifi, unit: .giga)
        let usageValue = PacketUsageConverter.get(dataUsage: dataUsageCount!, of: .wwan, unit: .giga)
        self.setCurrentMonthValueLabelAndButton(usermax: usermax, andWifiUsage: savingUsageValue, andCellularUsage: usageValue)
    }

    enum SegmentType : Int {
        case USAGE = 0,
        REMAIN,
        SAVE,
        MAX_SEGMENT_TYPE
        
        func toString() -> String {
            switch self {
            case SegmentType.USAGE:
                return NSLocalizedString("month_usage", comment:"")
            case SegmentType.REMAIN:
                return NSLocalizedString("month_remain", comment:"")
            case SegmentType.SAVE:
                return NSLocalizedString("month_save", comment:"")
            default:
                return ""
            }
        }
    }
    
    enum UsageProgessStats : Int {
        case GOOD = 0,
        FINE,
        CAUTION,
        DANGEROUS
        
        func getStatusPartsName() -> String {
            switch self {
            case UsageProgessStats.DANGEROUS:
                return "cat_dangerous"
            case UsageProgessStats.CAUTION:
                return "cat_caution"
            case UsageProgessStats.FINE:
                return "cat_fine"
            case UsageProgessStats.GOOD:
                return "cat_good"
            }
        }
        
        func getJarashiName() -> String {
            switch self {
            case UsageProgessStats.DANGEROUS:
                return "jarashi_dangerous"
            case UsageProgessStats.CAUTION:
                return "jarashi_caution"
            case UsageProgessStats.FINE:
                return "jarashi_fine"
            case UsageProgessStats.GOOD:
                return "jarashi_good"
            }
        }
    }
}
