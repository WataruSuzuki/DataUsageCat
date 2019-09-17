//
//  DUCNetworkInterFace.h
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2013/07/15.
//  Copyright (c) 2013年 Wataru Suzuki. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ifaddrs.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
//#import <net/if_types.h>

enum{
    IFA_DATA_WIFI_SEND,
    IFA_DATA_WIFI_RECEIVED,
    IFA_DATA_WWAN_SEND,
    IFA_DATA_WWAN_RECEIVED,
    IFA_DATA_GET_DATE,
    //IFA_DATA_GET_TIME,
};

@interface DUCNetworkInterFace : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithWifiSend:(long long)wifiSend
                    wifiReceived:(long long)wifiReceived
                        wwanSend:(long long)wwanSend
                    wwanReceived:(long long)wwanReceived
                         dateStr:(NSString *)dateStr NS_DESIGNATED_INITIALIZER;

@property (nonatomic) long long wifiSend;
@property (nonatomic) long long wifiReceived;
@property (nonatomic) long long wwanSend;
@property (nonatomic) long long wwanReceived;

@property (nonatomic, strong) NSString* dateStr;

+ (DUCNetworkInterFace *)getDataCounters;
//@property (NS_NONATOMIC_IOSONLY, getter=dataCounters, readonly, copy) NSArray *dataCounters;
//+ (DUCNetworkInterFace *)generateNetWorkInterFaceFromArray:(NSArray *)currentArray;
//+ (long long)getLongLongValueFromArray:(NSArray *)array
//                                       andObjectIndex:(int)index;

@end
