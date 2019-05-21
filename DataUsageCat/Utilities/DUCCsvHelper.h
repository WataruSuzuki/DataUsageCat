//
//  DJK_CsvHelper.h
//  DataUsageCat
//
//  Created by Wataru Suzuki on 2014/01/01.
//  Copyright (c) 2014年 Wataru Suzuki. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DUCNetworkInterFace.h"

enum{
    FILE_INDEX_THIS_MONTH,
    FILE_INDEX_LAST_MONTH,
    MAX_FILE_INDEX_NUM
};

@interface DUCCsvHelper : NSObject

//extern NSString * const DATE_FORMAT_FOR_CSV;
//extern NSString * const DATETIME_FORMAT_FOR_CSV;

- (NSMutableArray *)readCsvFile:(int)fileIndex;
- (NSMutableArray *)writeCsvFile:(NSArray *)arrayThisMonth
                    withNewArray:(NSArray *)arrayNewAdditions
                        andMonth:(int)monthIndex;
- (void)removeCsvFile;
+(NSArray *)getUsageResultFromCsv:(NSArray *)thisMonthArray
                     andLastMonth:(NSArray *)lastMonthArray;

@end
