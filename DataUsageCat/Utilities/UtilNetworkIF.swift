//
//  UtilNetworkIF.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/06/01.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit

class UtilNetworkIF: NetService {
    
    var wifiSend: Int64 = 0
    var wifiReceived: Int64 = 0
    var wwanSend: Int64 = 0
    var wwanReceived: Int64 = 0

    private static func getResultValue(newValue: Int64, lastSavedData lastSavedValue: Int64, offsetData offsetValue: Int64) -> Int64 {
        var ret = (lastSavedValue + newValue - offsetValue)
        if 0 != lastSavedValue && lastSavedValue > ret {
            ret = newValue + lastSavedValue
        }
        if ret < 0 {
            ret = Int64(0)
        }
        return ret
    }
    
    static func addOffsetValueToUsageData(currentData: DUCNetworkInterFace, lastSavedData lastSavedUsage: DUCNetworkInterFace, offsetData offsetUsage: DUCNetworkInterFace) -> DUCNetworkInterFace {
        let WiFiSent = getResultValue(newValue: currentData.wifiSend, lastSavedData: lastSavedUsage.wifiSend, offsetData: offsetUsage.wifiSend)
        let WiFiReceived = getResultValue(newValue: currentData.wifiReceived, lastSavedData: lastSavedUsage.wifiReceived, offsetData: offsetUsage.wifiReceived)
        let WWANSent = getResultValue(newValue: currentData.wwanSend, lastSavedData: lastSavedUsage.wwanSend, offsetData: offsetUsage.wwanSend)
        let WWANReceived = getResultValue(newValue: currentData.wwanReceived, lastSavedData: lastSavedUsage.wwanReceived, offsetData: offsetUsage.wwanReceived)
        
        return DUCNetworkInterFace(wifiSend: WiFiSent, wifiReceived: WiFiReceived, wwanSend: WWANSent, wwanReceived: WWANReceived, dateStr: nil)
    }
    
    class func getUsageValue(networkIf: DUCNetworkInterFace) -> Int64 {
        return networkIf.wwanSend + networkIf.wwanReceived
    }
    
    class func getSavingValue(networkIf: DUCNetworkInterFace) -> Int64 {
        return networkIf.wifiSend + networkIf.wifiReceived
    }
    
    class func getWifiDataUsageByGigaByte(dataUsage: DUCNetworkInterFace) -> Float {
        var wifiUsageValue = calcByteData(value: dataUsage.wifiSend, unit: .GIGA)
        wifiUsageValue += calcByteData(value: dataUsage.wifiReceived, unit: .GIGA)
        return wifiUsageValue
    }
    
    class func getCellularDataUsageByGigaByte(dataUsage: DUCNetworkInterFace) -> Float {
        var usageValue = calcByteData(value: dataUsage.wwanSend, unit: .GIGA)
        usageValue += calcByteData(value: dataUsage.wwanReceived, unit: .GIGA)
        return usageValue
    }
    
    class func getCellularDataUsageByMegaByte(dataUsage: DUCNetworkInterFace) -> Float {
        let wwanValue = dataUsage.wwanSend + dataUsage.wwanReceived
        return calcByteData(value: wwanValue, unit: .MEGA)
    }
    
    class func getWifiDataUsageByMegaByte(dataUsage: DUCNetworkInterFace) -> Float {
        let wifiValue = dataUsage.wifiSend + dataUsage.wifiReceived
        return calcByteData(value: wifiValue, unit: .MEGA)
    }
    
    class func calcByteData(value: Int64, unit: ByteUnit) -> Float {
        var calcedValue = Float(value)
        
        for num in 1...unit.rawValue {
            calcedValue /= Float(1000)
            #if ENABLE_SWIFT_LOG
            print("calcedValue = \(calcedValue)" + (ByteUnit(rawValue: num)?.toString())!)
            #endif//ENABLE_SWIFT_LOG
        }
        return calcedValue
    }
    
    enum ByteUnit: Int {
        case KILO = 1,
        MEGA,
        GIGA
        
        func toString() -> String {
            switch self {
            case .KILO: return "KB"
            case .MEGA: return "MB"
            case .GIGA: return "GB"
            }
        }
    }
}
