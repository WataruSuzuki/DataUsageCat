//
//  DUCNetworkInterFace.m
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2013/07/15.
//  Copyright (c) 2013年 Wataru Suzuki. All rights reserved.
//

#import "DUCNetworkInterFace.h"

@implementation DUCNetworkInterFace

@synthesize wifiSend;
@synthesize wifiReceived;
@synthesize wwanSend;
@synthesize wwanReceived;

-(DUCNetworkInterFace *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    long long WiFiSent = 0LL;
    long long WiFiReceived = 0LL;
#if TARGET_OS_SIMULATOR
    long long WWANSent     =  100000000LL;//0.1GB
    long long WWANReceived = 2000000000LL;//2.0GB
              WWANReceived =  6LL *100LL/*MB*/ *1000LL/*KB*/ *1000LL/*Byte*/;
#else//TARGET_OS_SIMULATOR
    long long WWANSent = 0LL;
    long long WWANReceived = 0LL;
#endif//TARGET_OS_SIMULATOR
    
    NSString *name;
    //NSString *name=[[[NSString alloc]init]autorelease];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
#ifdef ENABLE_LOG_NETWORK_INTERFACE
            NSLog(@"ifa_name %s == %@\n", cursor->ifa_name,name);
#endif//ENABLE_LOG_NETWORK_INTERFACE
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
#ifdef ENABLE_LOG_NETWORK_INTERFACE
                    NSLog(@"WiFi ifi_obytes=%d",networkStatisc->ifi_obytes);
                    NSLog(@"WiFi ifi_ipackets=%d",networkStatisc->ifi_ibytes);
                    NSLog(@"WiFi ifi_opackets=%d",networkStatisc->ifi_opackets);
                    NSLog(@"WiFi ifi_ipackets=%d",networkStatisc->ifi_ipackets);
#endif//ENABLE_LOG_NETWORK_INTERFACE
                    
                    WiFiSent += [self getNetworkStatiscIfiValue:networkStatisc->ifi_obytes];
                    WiFiReceived += [self getNetworkStatiscIfiValue:networkStatisc->ifi_ibytes];
#ifdef ENABLE_LOG_NETWORK_INTERFACE
                    NSLog(@"WiFiSent =%lluu",WiFiSent);
                    NSLog(@"WiFiReceived =%llu",WiFiReceived);
#endif//ENABLE_LOG_NETWORK_INTERFACE
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
#ifdef ENABLE_LOG_NETWORK_INTERFACE
                    NSLog(@"WWAN ifi_obytes=%d",networkStatisc->ifi_obytes);
                    NSLog(@"WWAN ifi_ipackets=%d",networkStatisc->ifi_ibytes);
                    NSLog(@"WWAN ifi_opackets=%d",networkStatisc->ifi_opackets);
                    NSLog(@"WWAN ifi_ipackets=%d",networkStatisc->ifi_ipackets);
#endif//ENABLE_LOG_NETWORK_INTERFACE
                    
                    WWANSent += [self getNetworkStatiscIfiValue:networkStatisc->ifi_obytes];
                    WWANReceived += [self getNetworkStatiscIfiValue:networkStatisc->ifi_ibytes];
#ifdef ENABLE_LOG_NETWORK_INTERFACE
                    NSLog(@"WWANSent =%llu",WWANSent);
                    NSLog(@"WWANReceived =%llu",WWANReceived);
#endif//ENABLE_LOG_NETWORK_INTERFACE
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return [self generateNetWorkInterFaceFromArray:@[@(WiFiSent),@(WiFiReceived),@(WWANSent),@(WWANReceived)]];
}

-(long long)getNetworkStatiscIfiValue:(int)ifiValue
{
    long long ret = (long long)ifiValue;
    
    if (0 > ifiValue) {
        ret += (long long)INT32_MAX;
    }
    
    if (0 > ret) {
        ret = 0LL;
    }
    return ret;
}

-(long long)getLongLongValueFromArray:(NSArray *)array
                       andObjectIndex:(int)index
{
    NSNumber *numberObj =(NSNumber *)array[index];
    long long ret = [numberObj longLongValue];
    
    return ret;
}

-(DUCNetworkInterFace *)generateNetWorkInterFaceFromArray:(NSArray *)currentArray
{
    NSArray *array = nil;
    DUCNetworkInterFace *networkInterFace = [[DUCNetworkInterFace alloc] init];
    if (nil != currentArray) {
        array = currentArray;
        
        networkInterFace.wifiSend = [self getLongLongValueFromArray:array andObjectIndex:IFA_DATA_WIFI_SEND];
        networkInterFace.wifiReceived = [self getLongLongValueFromArray:array andObjectIndex:IFA_DATA_WIFI_RECEIVED];
        
        networkInterFace.wwanSend = [self getLongLongValueFromArray:array andObjectIndex:IFA_DATA_WWAN_SEND];
        networkInterFace.wwanReceived = [self getLongLongValueFromArray:array andObjectIndex:IFA_DATA_WWAN_RECEIVED];
    }
    
    return networkInterFace;
}

@end
