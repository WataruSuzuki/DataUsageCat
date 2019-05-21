//
//  DJKUtilLocale.m
//  DJKUtilities
//
//  Created by Wataru Suzuki on 2014/11/09.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

#import "DJKUtilLocale.h"

@implementation DJKUtilLocale

NSString * const DATE_FORMAT_FOR_CSV = @"yyyy.MM.dd";
NSString * const DATETIME_FORMAT_FOR_CSV = @"yyyy.MM.dd HH:mm";

+(BOOL)isLocaleJapanese{
    NSArray *languages = [NSLocale preferredLanguages];
    // 取得したリストの0番目に、現在選択されている言語の言語コード(日本語なら”ja”)が格納されるので、NSStringに格納します.
    NSString *languageID = languages[0];
    NSString *languageWithoutRegions = [[languageID componentsSeparatedByString:@"-"] firstObject];
    
    // 日本語の場合はYES
    if ([languageID isEqualToString:@"ja"]
        || [languageWithoutRegions isEqualToString:@"ja"]
        ) {
        return YES;
    }
    
    // 日本語の以外はNO
    return NO;
}

+(NSString *)getFormatedDateStrByStyle:(NSDateFormatterStyle)style
                           withDateStr:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = DATE_FORMAT_FOR_CSV;
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:style];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    NSString* localizedDateStr = [dateFormatter stringFromDate:date];
    
    return localizedDateStr;
}

@end
