//
//  SelectedWeekChartView.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/06/03.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

/*
 * "Hello Swift, Goodbye Obj-C."
 * Converted by 'objc2swift'
 *
 * https://github.com/yahoojapan/objc2swift
 */
import UIKit

class SelectedWeekChartView: UIView {
    
    let LIMIT_HEIGHT_IMAGE_UNIT = Int64(1000000000)
    
    var focusViewPosition = 0
    var userDefaultLimit = Float(0.0)
    var arrayFocusView: [UIView]!
    var arrayChartView: [UIView]!
    var arrayWifiChartView: [UIView]!
    var arrayFocusViewImage: [UIView]!
    
    @IBOutlet weak var focusView_01: UIView!
    @IBOutlet weak var focusView_02: UIView!
    @IBOutlet weak var focusView_03: UIView!
    @IBOutlet weak var focusView_04: UIView!
    @IBOutlet weak var focusView_05: UIView!
    @IBOutlet weak var focusView_06: UIView!
    @IBOutlet weak var focusView_07: UIView!
    @IBOutlet weak var focusViewImage_01: UIImageView!
    @IBOutlet weak var focusViewImage_02: UIImageView!
    @IBOutlet weak var focusViewImage_03: UIImageView!
    @IBOutlet weak var focusViewImage_04: UIImageView!
    @IBOutlet weak var focusViewImage_05: UIImageView!
    @IBOutlet weak var focusViewImage_06: UIImageView!
    @IBOutlet weak var focusViewImage_07: UIImageView!
    @IBOutlet weak var chartView_01: UIView!
    @IBOutlet weak var chartView_02: UIView!
    @IBOutlet weak var chartView_03: UIView!
    @IBOutlet weak var chartView_04: UIView!
    @IBOutlet weak var chartView_05: UIView!
    @IBOutlet weak var chartView_06: UIView!
    @IBOutlet weak var chartView_07: UIView!
    @IBOutlet weak var chartWifiView_01: UIView!
    @IBOutlet weak var chartWifiView_02: UIView!
    @IBOutlet weak var chartWifiView_03: UIView!
    @IBOutlet weak var chartWifiView_04: UIView!
    @IBOutlet weak var chartWifiView_05: UIView!
    @IBOutlet weak var chartWifiView_06: UIView!
    @IBOutlet weak var chartWifiView_07: UIView!
    
    class func instanceFromNib(currentView: UIView) -> SelectedWeekChartView {
        let nib = UINib(nibName: "SelectedWeekChartView", bundle: nil)
        let newChartView = nib.instantiate(withOwner: nil, options: nil)[0] as! SelectedWeekChartView
        
        newChartView.frame.size.width = currentView.window!.frame.size.width
        newChartView.frame.size.height = currentView.frame.size.height
        newChartView.setViewArray()
        
        return newChartView
    }
    
    func setViewArray() {
        arrayFocusView = [focusView_01,
                          focusView_02,
                          focusView_03,
                          focusView_04,
                          focusView_05,
                          focusView_06,
                          focusView_07]
        arrayFocusViewImage = [focusViewImage_01,
                              focusViewImage_02,
                              focusViewImage_03,
                              focusViewImage_04,
                              focusViewImage_05,
                              focusViewImage_06,
                              focusViewImage_07]
        arrayChartView = [chartView_01,
                          chartView_02,
                          chartView_03,
                          chartView_04,
                          chartView_05,
                          chartView_06,
                          chartView_07]
        arrayWifiChartView = [chartWifiView_01,
                              chartWifiView_02,
                              chartWifiView_03,
                              chartWifiView_04,
                              chartWifiView_05,
                              chartWifiView_06,
                              chartWifiView_07]
    }
    
    func getDayReferenceValue(userMax: Float) -> Int64 {
        if 0 < userMax {
            return Int64((userMax * Float(LIMIT_HEIGHT_IMAGE_UNIT)) / Float(30))
        }
        return LIMIT_HEIGHT_IMAGE_UNIT
    }
    
    func setFocusViewImageDispStatus(position: Int) {
        self.focusViewPosition = position
        for count in 0 ..< arrayFocusView.count {
            let view = arrayFocusView[count]
            let imageview = arrayFocusViewImage[count]
            view.layer.borderColor = UIColor(red: 0, green: 0.392, blue: 0, alpha: 1.0).cgColor
            if count == position {
                imageview.isHidden = false
                view.layer.borderWidth = 1.0
            } else {
                imageview.isHidden = true
                view.layer.borderWidth = 0.0
            }
        }
    }
    
    func initChartViewColor() {
        var count = 0
        for chartView: UIView in arrayChartView {
            chartView.backgroundColor = UIColor.clear
            let chartWifiView = arrayWifiChartView[count]
            chartWifiView.backgroundColor = UIColor.clear
            count += 1
        }
    }
    
    func setHiddenChartViewImageWithStatus(hidden: Bool) {
        var count = 0
        for chartView: UIView in arrayChartView {
            chartView.isHidden = hidden
            let chartWifiView = arrayWifiChartView[count]
            chartWifiView.isHidden = hidden
            count += 1
        }
    }
    
    func setHiddenFocusViewImageWithStatus(hidden: Bool) {
        for count in 0 ..< arrayFocusView.count {
            let imageview = arrayFocusViewImage[count]
            imageview.isHidden = hidden
            let view = arrayFocusView[count]
            view.layer.borderWidth = 0.0
        }
    }
    
    func setChartBarFrames(usageValueArray: [Any], withUsageViewArray viewArray: [UIView], withSavingArray savingArray: [UIView]) {
        for count in 0 ..< usageValueArray.count {
            let usageView = viewArray[count]
            let wifiView = savingArray[count]
            if let dataOfDay = DUCNetworkInterFace().generateNetWork(from: usageValueArray[count] as! [AnyObject]) {
                let usageValue = dataOfDay.wwanSend + dataOfDay.wwanReceived
                let savingValue = dataOfDay.wifiSend + dataOfDay.wifiReceived
                let referenceValue = self.getDayReferenceValue(userMax: userDefaultLimit)
                usageView.frame = self.getFrameForWeekChartWithFrame(currentFrame: usageView.frame, withValue: usageValue, withLimit: referenceValue)
                usageView.backgroundColor = SelectedWeekChartView.getUsageChartBarColor(usageValue: usageValue, withMaxReference: referenceValue)
                wifiView.frame = self.getFrameForWeekChartWithFrame(currentFrame: wifiView.frame, withValue: savingValue, withLimit: referenceValue)
                wifiView.backgroundColor = UIColor(red: 0, green: 0.48, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    class func getUsageChartBarColor(usageValue: Int64, withMaxReference maxReferenceValue: Int64) -> UIColor {
        switch SelectedWeekChartView.getChartStatus(usageDayValue: usageValue, withMaxReference: maxReferenceValue) {
        case .FINE:
            return UIColor(red: 1.0, green: 0.82, blue: 0, alpha: 1.0)
                   
        case .CAUTION:
            return UIColor(red: 1.0, green: 0.6, blue: 0, alpha: 1.0)
                   
        case .DANGEROUS:
            return UIColor.red
                   
        default:
            return UIColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    func getFrameForWeekChartWithFrame(currentFrame: CGRect, withValue chartValue: Int64, withLimit limitValue: Int64) -> CGRect {
        var frame = currentFrame
        let limitOffset = limitValue * 2
        if chartValue >= limitOffset {
            return frame
        }
        let chartValueGigaByte = UtilNetworkIF.calcByteData(value: chartValue, unit: UtilNetworkIF.ByteUnit.GIGA)
        let limitValueGigaByte = UtilNetworkIF.calcByteData(value: limitOffset, unit: UtilNetworkIF.ByteUnit.GIGA)
        let offsetHeightValue = (chartValueGigaByte / limitValueGigaByte) 
        frame.size.height = frame.size.height * CGFloat(offsetHeightValue)
        let offsetOriginY = currentFrame.size.height - currentFrame.size.height * CGFloat(offsetHeightValue)
        frame.origin.y = frame.origin.y + offsetOriginY
        return frame
    }
    
    class func getChartStatus(usageDayValue: Int64, withMaxReference maxReferenceValue: Int64) -> ChartStatus {
        if maxReferenceValue <= usageDayValue {
            return .DANGEROUS
        } else if (Float(maxReferenceValue) * 0.66) <= Float(usageDayValue) {
            return .CAUTION
        } else if (Float(maxReferenceValue) * 0.33) <= Float(usageDayValue) {
            return .FINE
        } else {
            return .GOOD
        }
    }
    
    class func getPositionOfWeek(page: Int, withTotalPage totalPages: Int, unitPerPage perPageNum: Int) -> Int {
        var ret = 0
        if 0 == (totalPages % perPageNum) {
            ret = (page % perPageNum)
        } else {
            var offsetValue = 0
            for _ in 0 ..< 100 {
                if offsetValue > (totalPages - 1) {
                    break
                } else {
                    offsetValue += perPageNum
                }
            }
            ret = page % perPageNum + (offsetValue - totalPages)
            if perPageNum <= ret {
                ret -= perPageNum
            }
        }
        return ret
    }
    
    class func getIndexOfTotalData(position: Int, withNextPosition nextPosition: Int, withCurrentPage currentpage: Int) -> Int {
        var ret = 0
        var index = currentpage + (nextPosition - position)
        if 0 > index {
            index = 0
        }
        ret = index
        return ret
    }
    
    class func updateArrayDispThisWeekWithPage(page: Int, unitPerPage perPageNum: Int, withNextPosition position: Int, withDataArray dataArray: [Any]) -> [Any] {
        var arrayThisWeek = [Any]()
        var index = (page - position)
        
        for _ in 0..<perPageNum {
            if (0 < index
                && index >= dataArray.count
                ) {
                break;
            }
            if (index < 0 || dataArray.count <= 0) {
                let emptyArray = [0, 0, 0, 0, ""] as [Any]
                arrayThisWeek.append(emptyArray as AnyObject)
            } else {
                arrayThisWeek.append(dataArray[index])
            }
            index += 1
        }
        
        return arrayThisWeek
    }
    
    class func createWeekChartPage(weekPage: Int, withDay selectedDayPage: Int, withParentView parentView: UIScrollView, arrayThisMonth arrayThisMonthUsage: [Any], unitPerPage: Int, userDefaultLimit limit: Float, IsCurrentPage isVisiblePage: Bool) -> SelectedWeekChartView {
        let newChartview = SelectedWeekChartView.instanceFromNib(currentView: parentView)
        newChartview.initChartViewColor()
        newChartview.frame.origin.y = 0
        if UIDevice.current.userInterfaceIdiom == .pad {
            newChartview.frame.size.width = parentView.frame.size.width
        }
        newChartview.frame.origin.x = newChartview.frame.width * CGFloat(weekPage)
        //print("parentView.frame = \(parentView.frame)")
        //print("newChartview.frame = \(newChartview.frame)")
        
        newChartview.userDefaultLimit = limit
        let position = getPositionOfWeek(page: selectedDayPage, withTotalPage: Int(arrayThisMonthUsage.count), unitPerPage: unitPerPage)
        newChartview.setFocusViewImageDispStatus(position: position)
        
        let arrayDispThisWeek = updateArrayDispThisWeekWithPage(page: selectedDayPage, unitPerPage: unitPerPage, withNextPosition: position, withDataArray: arrayThisMonthUsage)
        newChartview.setChartBarFrames(usageValueArray: arrayDispThisWeek, withUsageViewArray: newChartview.arrayChartView, withSavingArray: newChartview.arrayWifiChartView)
        
        parentView.addSubview(newChartview)
        
        if (!isVisiblePage) {
            newChartview.setHiddenChartViewImageWithStatus(hidden: true)
        }
        
        return newChartview;
    }
    
    enum ChartStatus : Int {
        case GOOD = 0,
        FINE,
        CAUTION,
        DANGEROUS
    }
    
    enum PageScroll : Int {
        case FIRST_DAY = 0,
        SECOND_DAY,
        THRID_DAY,
        FOURTH_DAY,
        FIFTH_DAY,
        SIXTH_DAY,
        LAST_DAY,
        MAX_PAGE
    }
    
}
