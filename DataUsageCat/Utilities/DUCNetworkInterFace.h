//
//  DUCNetworkInterFace.h
//  DataUsageCat
//
//  Created by 鈴木 航 on 2013/07/15.
//  Copyright (c) 2013年 鈴木 航. All rights reserved.
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

@interface DUCNetworkInterFace : NSNetService
{
    //Nothing
}
@property (getter=wifiSend, nonatomic) long long wifiSend;
@property (getter=wifiReceived, nonatomic) long long wifiReceived;
@property (getter=wwanSend, nonatomic) long long wwanSend;
@property (getter=wwanReceived, nonatomic) long long wwanReceived;

-(DUCNetworkInterFace *)getDataCounters;
//@property (NS_NONATOMIC_IOSONLY, getter=dataCounters, readonly, copy) NSArray *dataCounters;
-(DUCNetworkInterFace *)generateNetWorkInterFaceFromArray:(NSArray *)currentArray;
//+(long long)getLongLongValueFromArray:(NSArray *)array
//                                       andObjectIndex:(int)index;

@end
