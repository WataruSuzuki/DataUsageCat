//
//  DJKUtilLocale.h
//  DJKUtilities
//
//  Created by Wataru Suzuki on 2014/11/09.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJKUtilLocale : NSObject

extern NSString * const DATE_FORMAT_FOR_CSV;
extern NSString * const DATETIME_FORMAT_FOR_CSV;

+(BOOL)isLocaleJapanese;
+(NSString *)getFormatedDateStrByStyle:(NSDateFormatterStyle)style
                           withDateStr:(NSString *)dateStr;

@end
