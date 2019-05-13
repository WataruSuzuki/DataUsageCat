//
//  DJK_CsvHelper.m
//  DataUsageCat
//
//  Created by 鈴木 航 on 2014/01/01.
//  Copyright (c) 2014年 鈴木 航. All rights reserved.
//

#import "DUCCsvHelper.h"
#import "DUCNetworkInterFace.h"
#import "DJKUtilLocale.h"
#import <UIKit/UIKit.h>
#import "DataUsageCat-Swift.h"

@implementation DUCCsvHelper

//NSString * const DATE_FORMAT_FOR_CSV = @"yyyy.MM.dd";
//NSString * const DATETIME_FORMAT_FOR_CSV = @"yyyy.MM.dd HH:mm";

/* csvファイルからデータを読み取る */
- (NSMutableArray *)readCsvFile:(int)fileIndex
{
    NSMutableArray *retMutableArray = [NSMutableArray array];
    
    // CSVファイルからセクションデータを取得する.
    NSString *documentsDirectory = [self getCsvDatasDocumentsPath];
    
    // データ保存用のディレクトリを作成する.
    if ([self makeDirForAppContents]) {
        // ディレクトリに対して「do not backup」属性をセット.
        NSURL *dirUrl = [NSURL fileURLWithPath:documentsDirectory];
        [self addSkipBackupAttributeToItemAtURL:dirUrl];
    }
    NSString *fileName = [self getCsvFileName:fileIndex];
    NSString* csvFileThisMonth = [documentsDirectory stringByAppendingPathComponent:fileName];
    retMutableArray = [self getCsvParsedData:csvFileThisMonth];
    
    return retMutableArray;
}

-(NSMutableArray *)getCsvParsedData:(NSString *)csvFile
{
    NSMutableArray *parsedCsvMutableArray = [NSMutableArray array];
    //ファイルの有無を確認.
    if ([[NSFileManager defaultManager] fileExistsAtPath:csvFile]) {
        
        NSData *csvData = [NSData dataWithContentsOfFile:csvFile];
        NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
        
        NSScanner *scanner = [NSScanner scannerWithString:csv];
        
        // 改行文字の集合を取得.
        NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
        // 一行ずつの読み込み.
        NSString *line;
        while (![scanner isAtEnd]) {
            // 一行読み込み.
            [scanner scanUpToCharactersFromSet:chSet intoString:&line];
            // カンマ「,」で区切る.
            NSArray *recodeArray = [line componentsSeparatedByString:@","];
            //NSLog(@"recodeArray = %@", recodeArray);
            [parsedCsvMutableArray addObject:recodeArray];
            
            /*データをarrayから取得してデータにセット*/
            //　改行文字をスキップ.
            [scanner scanCharactersFromSet:chSet intoString:NULL];
        }
        //NSLog(@"csv = %@", csv);
        //NSLog(@"scanner = %@", scanner);
        //NSLog(@"line = %@", line);
    }
    
    return parsedCsvMutableArray;
}

- (void)removeCsvFile
{
    NSString *fileNameThisMonth = [self getCsvFileName:FILE_INDEX_THIS_MONTH];
    NSString *fileNameLastMonth = [self getCsvFileName:FILE_INDEX_LAST_MONTH];
    
    NSFileManager *fileManager=[[NSFileManager alloc] init];
    NSError *error = nil;

    NSString *documentsDirectory = [self getCsvDatasDocumentsPath];
    
    // データ保存用のディレクトリを作成する.
    if ([self makeDirForAppContents]) {
        // ディレクトリに対して「do not backup」属性をセット.
        NSURL *dirUrl = [NSURL fileURLWithPath:documentsDirectory];
        [self addSkipBackupAttributeToItemAtURL:dirUrl];
    }

    /* 全てのファイル名 */
    NSArray *allFileName = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error) return;
    
    for (NSString *fileName in allFileName) {
        if (![fileName isEqualToString:fileNameThisMonth]
            && ![fileName isEqualToString:fileNameLastMonth]) {
            NSString *removePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:removePath error:NULL];
        }
    }
}

/* csvファイルにデータを書き込む */
- (NSMutableArray *)writeCsvFile:(NSArray *)arrayThisMonth
                    withNewArray:(NSArray *)arrayNewAdditions
                        andMonth:(int)monthIndex
{
    NSString *mstr = [NSMutableString stringWithString:@""];
    //ファイルパスを取得.
    NSString *documentsDirectory = [self getCsvDatasDocumentsPath];
    
    // データ保存用のディレクトリを作成する.
    if ([self makeDirForAppContents]) {
        // ディレクトリに対して「do not backup」属性をセット.
        NSURL *dirUrl = [NSURL fileURLWithPath:documentsDirectory];
        [self addSkipBackupAttributeToItemAtURL:dirUrl];
    }
    NSString *strDate = [self getDateString];
    NSString *strTimeNow = [self getDateTimeNowString];
    
    NSString *strFileName = [self getCsvFileName:monthIndex];
    //NSString *strFileName = [self getCsvFileName:FILE_INDEX_THIS_MONTH];
    NSString* documents_and_file_dir = [documentsDirectory stringByAppendingPathComponent:strFileName];
    
    //ファイル書き込み.
    NSData* out_data = [mstr dataUsingEncoding:NSUTF8StringEncoding];
    [out_data writeToFile:documents_and_file_dir atomically:YES];
    
    //ファイル操作.
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 既存チェック.
    if (![fileManager fileExistsAtPath:documents_and_file_dir]) {
        // 新規の場合は空のファイルを作成.
        [fileManager createFileAtPath:documents_and_file_dir contents:[NSData data] attributes:nil];
    }
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:documents_and_file_dir];
    NSMutableArray *csvArrayThisMonth = [NSMutableArray arrayWithArray:arrayThisMonth];
    if (nil != arrayNewAdditions) {
        NSMutableArray *csvArrayNewAdditions = [NSMutableArray arrayWithArray:arrayNewAdditions];
        [csvArrayNewAdditions addObject:strDate];
        [csvArrayNewAdditions addObject:strTimeNow];
        
        [csvArrayThisMonth addObject:csvArrayNewAdditions];
    }
    for (NSArray* recordArray in csvArrayThisMonth) {
        NSString *wifiSent = recordArray[IFA_DATA_WIFI_SEND];
        NSString *wifiReceived = recordArray[IFA_DATA_WIFI_RECEIVED];
        NSString *wwanSent = recordArray[IFA_DATA_WWAN_SEND];
        NSString *wwanReceived = recordArray[IFA_DATA_WWAN_RECEIVED];
        NSString *strDate = recordArray[IFA_DATA_GET_DATE];
        //NSString *strGetTime = [recordArray objectAtIndex:IFA_DATA_GET_TIME];
        //NSString* row = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n", wifiSent, wifiReceived, wwanSent, wwanReceived, strDate, strGetTime];
        NSString* row = [NSString stringWithFormat:@"%@,%@,%@,%@,%@\n", wifiSent, wifiReceived, wwanSent, wwanReceived, strDate];
        NSData* data = [row dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:data];
    }
    [fileHandle closeFile];
    
    return csvArrayThisMonth;
}

/* 格納先ディレクトリの作成 */
- (BOOL)makeDirForAppContents
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *baseDir = [self getCsvDatasDocumentsPath];
    
    BOOL exists = [fileManager fileExistsAtPath:baseDir];
    if (!exists) {
        NSError *error;
        BOOL created = [fileManager createDirectoryAtPath:baseDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!created) {
            NSLog(@"ディレクトリ作成失敗");
            return NO;
        }
    } else {
        return NO;
        // 作成済みの場合はNO.
    }
    return YES;
}

- (NSString *)getCsvDatasDocumentsPath
{
    NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"csvdatas"]; //追加するディレクトリ名を指定.
    return path;
}

-(NSString *)getCsvFileName:(int)fileIndex
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];// Localeの指定.
    [df setDateFormat:@"yyyyMM"];
    
    // 日付(NSDate) => 文字列(NSString)に変換.
    NSDate *date = [NSDate date];
    NSString *strFileName;
    if (fileIndex == FILE_INDEX_LAST_MONTH) {
        NSDateComponents *component = [self getDateComponents:date];
        NSInteger year = component.year;
        NSInteger month = 12;
        if (1 == component.month) {
            year--;
        } else {
            month = component.month - 1;
        }
        strFileName = [NSString stringWithFormat:@"%4ld%02ld%@", (long)year, (long)month, @".csv"];
    } else {
        //FILE_INDEX_THIS_MONTH
        strFileName = [NSString stringWithFormat:@"%@%@", [df stringFromDate:date], @".csv"];
    }
    
    return strFileName;
}

-(NSString *)getDateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];// Localeの指定.
    [df setDateFormat:DATE_FORMAT_FOR_CSV];
    
    // 日付(NSDate) => 文字列(NSString)に変換.
    NSDate *now = [NSDate date];
    NSString *strNow = [df stringFromDate:now];
    
    return strNow;
}

-(NSString *)getDateTimeNowString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];// Localeの指定.
    [df setDateFormat:DATETIME_FORMAT_FOR_CSV];
    
    // 日付(NSDate) => 文字列(NSString)に変換.
    NSDate *now = [NSDate date];
    NSString *strNow = [df stringFromDate:now];
    
    return strNow;
}

-(NSDateComponents *)getDateComponents:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps;
    dateComps = [calendar components:NSCalendarUnitYear
                 | NSCalendarUnitMonth
                 | NSCalendarUnitDay
                 | NSCalendarUnitHour
                 | NSCalendarUnitMinute
                 | NSCalendarUnitSecond
                            fromDate:date];
    return dateComps;
}

/*
 格納先ディレクトリをiCloudのバックアップ対象外に変更
 下記ソースは、これ（https://developer.apple.com/library/ios/#qa/qa1719/_index.html）を参考に。
*/
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    //とりあえずassertはコメントアウト.
    //assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: @YES
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+(NSArray *)getUsageResultFromCsv:(NSArray *)thisMonthArray
                     andLastMonth:(NSArray *)lastMonthArray
{
    NSArray *savedArray = [lastMonthArray arrayByAddingObjectsFromArray:thisMonthArray];
    /*
     NSMutableArrayでやるなら↓
     
     NSMutableArray *mAry1 = [NSMutableArray arrayWithArray:lastMonthArray];
     NSMutableArray *mAry2 = [NSMutableArray arrayWithArray:thisMonthArray];
     [mAry1 addObjectsFromArray:mAry2];
     
     */
    
    NSMutableArray *resultTotalArray = [[NSMutableArray alloc] init];
    
    long long wifiSent = 0;
    long long wifiReceived = 0;
    long long wwanSent = 0;
    long long wwanReceived = 0;
    
    for (NSArray* recordArray in savedArray) {
        NSString *strWifiSent = recordArray[IFA_DATA_WIFI_SEND];
        NSString *strWifiReceived = recordArray[IFA_DATA_WIFI_RECEIVED];
        NSString *strWwanSent = recordArray[IFA_DATA_WWAN_SEND];
        NSString *strWwanReceived = recordArray[IFA_DATA_WWAN_RECEIVED];
        NSString *strDate = recordArray[IFA_DATA_GET_DATE];
        
        NSMutableArray *lastCreateArray;
        if (0 != [resultTotalArray count]) {
            lastCreateArray = [resultTotalArray lastObject];
        }
        NSString *lastAddDayStr = lastCreateArray[IFA_DATA_GET_DATE];
        if (nil == lastCreateArray
            || [strDate isEqualToString:lastAddDayStr]
            ) {
            //同じ日付なので加算する.
            wifiSent += [strWifiSent longLongValue];
            wifiReceived += [strWifiReceived longLongValue];
            wwanSent += [strWwanSent longLongValue];
            wwanReceived += [strWwanReceived longLongValue];
        } else {
            //違う日付なので新しい格納先に加算する.
            wifiSent = [strWifiSent longLongValue];
            wifiReceived = [strWifiReceived longLongValue];
            wwanSent = [strWwanSent longLongValue];
            wwanReceived = [strWwanReceived longLongValue];
        }
        
        //配列に保存する.
        if (nil == lastCreateArray
            || ![strDate isEqualToString:lastAddDayStr]
            ) {
            //新しい格納先.
            NSMutableArray *resultDayArray = [[NSMutableArray alloc] init];
            [resultDayArray addObject:@(wifiSent)];
            [resultDayArray addObject:@(wifiReceived)];
            [resultDayArray addObject:@(wwanSent)];
            [resultDayArray addObject:@(wwanReceived)];
            [resultDayArray addObject:strDate];
            
            [resultTotalArray addObject:resultDayArray];
        } else {
            //同じ格納先を更新.
            lastCreateArray[IFA_DATA_WIFI_SEND] = @(wifiSent);
            lastCreateArray[IFA_DATA_WIFI_RECEIVED] = @(wifiReceived);
            lastCreateArray[IFA_DATA_WWAN_SEND] = @(wwanSent);
            lastCreateArray[IFA_DATA_WWAN_RECEIVED] = @(wwanReceived);
            lastCreateArray[IFA_DATA_GET_DATE] = strDate;
            
            resultTotalArray[[resultTotalArray count]-1] = lastCreateArray;
        }
    }
    
    return resultTotalArray;
}

@end
