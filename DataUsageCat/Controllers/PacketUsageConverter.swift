//
//  PacketUsageConverter.swift
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2016/06/01.
//  Copyright © 2016年 Wataru Suzuki. All rights reserved.
//

import UIKit

class PacketUsageConverter: NSObject {
    
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
    
    static func appendToUsageData(currentData: DUCNetworkInterFace, lastSavedData lastSavedUsage: DUCNetworkInterFace, offsetData offsetUsage: DUCNetworkInterFace) -> DUCNetworkInterFace {
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
    
    class func get(dataUsage: DUCNetworkInterFace, of: PacketType, unit: ByteUnit) -> Float {
        let values = (of == .wifi
            ? dataUsage.wifiSend + dataUsage.wifiReceived
            : dataUsage.wwanSend + dataUsage.wwanReceived)
        return calcByteData(value: values, unit: unit)
    }
    
    class func calcByteData(value: Int64, unit: ByteUnit) -> Float {
        var calcedValue = Float(value)
        
        for num in 1...unit.rawValue {
            calcedValue /= Float(1000)
            #if ENABLE_SWIFT_LOG
            print("calcedValue = \(calcedValue)" + (ByteUnit(rawValue: num)?.name())!)
            #endif//ENABLE_SWIFT_LOG
        }
        return calcedValue
    }
    
    enum PacketType: Int, CaseIterable {
        case wifi = 0,
        wwan
    }
    
    enum ByteUnit: Int {
        case kilo = 1,
        mega,
        giga
        
        func name() -> String {
            switch self {
            case .kilo: return "KB"
            case .mega: return "MB"
            case .giga: return "GB"
            }
        }
    }
}
