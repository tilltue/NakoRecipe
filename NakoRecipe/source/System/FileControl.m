//
//  FileControl.m
//  guitarNako
//
//  Created by nako on 10/30/12.
//  Copyright (c) 2012 nako. All rights reserved.
//

#import "FileControl.h"
#include <sys/xattr.h>
#import "XMLWriter.h"
#import "GDataXMLNode.h"

@implementation FileControl

+ (void)addSkipBackupAttributeToItemAtURL:(NSString *)path
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
}

+ (void)createCodeSaveDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingDirectory = [documentsDirectory stringByAppendingString:@"/Code"];
    NSFileManager *fmg;
    fmg = [NSFileManager defaultManager];
    if( [fmg fileExistsAtPath:savingDirectory] ){
    }else{
        [fmg createDirectoryAtPath:savingDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        [self addSkipBackupAttributeToItemAtURL:savingDirectory];
    }
}

+ (NSMutableArray *)getListScoreFile
{
    NSMutableArray *scoreFileList;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingDirectory = [documentsDirectory stringByAppendingString:@"/Code"];
    NSFileManager *fmg;
    fmg = [NSFileManager defaultManager];
    if( [fmg fileExistsAtPath:savingDirectory] ){
        NSArray *filelist = [fmg contentsOfDirectoryAtPath:savingDirectory error:NULL];
        scoreFileList = [[NSMutableArray alloc] initWithArray:filelist];
        return scoreFileList;
    }else{
        return nil;
    }
    return scoreFileList;
}

+ (void)convertDataToMusicSheetArray:(NSMutableArray *)musicSheets withXMLWriter:(XMLWriter *)xmlWriter
{
    NSInteger codeStepCount;
    NSMutableDictionary *tempDic;
    NSMutableArray *tempCodeInfos;
    CodeInfo *tempCodeInfo;
    NSString *mSheetTag = @"SHEET";
    NSString *stepTag = @"STEP";
    NSString *codeTag = @"CODE";
	   
    for( int i=0;i<[musicSheets count]; i++)
    {
        [xmlWriter writeStartElement:mSheetTag];
        [xmlWriter writeAttribute:@"sheet_count" value:[NSString stringWithFormat:@"%d",i]];
        tempDic = [musicSheets objectAtIndex:i];
        if( tempDic != nil){
            codeStepCount = [[tempDic allKeys] count];
            for( int j=0;j<codeStepCount;j++)
            {
                [xmlWriter writeStartElement:stepTag];
                [xmlWriter writeAttribute:@"step_count" value:[NSString stringWithFormat:@"%d",j]];
                tempCodeInfos = [tempDic objectForKey:[NSString stringWithFormat:@"%d",j]];
                if( tempCodeInfos != nil){
                    for( int k=0; k< [tempCodeInfos count];k++)
                    {
                        tempCodeInfo = [tempCodeInfos objectAtIndex:k];
                        if( tempCodeInfo != nil){
                            [xmlWriter writeStartElement:codeTag];
                            [xmlWriter writeAttribute:@"code_name" value:[NSString stringWithFormat:@"%@",tempCodeInfo.codeName]];
                            [xmlWriter writeAttribute:@"rhythm" value:[NSString stringWithFormat:@"%d",tempCodeInfo.rhythm]];
                            [xmlWriter writeEndElement:codeTag];
                        }
                    }
                    [xmlWriter writeEndElement:stepTag];
                }else{
                    [xmlWriter writeEndElement:stepTag];
                }
            }
            [xmlWriter writeEndElement:mSheetTag];
        }else{
            [xmlWriter writeEndElement:mSheetTag];
        }
    }
}

+ (void)saveMusicSheet:(NSString *)mSheetName withCodeInfoArrayInMusicSheet:(NSMutableArray *)codeInfoInMusicSheet
{
    [self createCodeSaveDir];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingFileName = [mSheetName stringByAppendingString:@"_Code.cod"];
    NSString *savingFilePath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/Code/%@",savingFileName]];
    
    NSFileManager *fmg;
    NSData *convertData = nil;
    XMLWriter *xmlWriter;
    xmlWriter = [[XMLWriter alloc] init];
    NSString *gScoreName = @"GUITAR_SCORE";
    
    [xmlWriter writeStartElement:gScoreName];
    [self convertDataToMusicSheetArray:codeInfoInMusicSheet withXMLWriter:xmlWriter];
    [xmlWriter writeEndElement:gScoreName];
	
	//NSLog(@"%@", [xmlWriter toString]);
    
    fmg = [NSFileManager defaultManager];
    convertData = [[xmlWriter toString] dataUsingEncoding:NSUTF8StringEncoding];
    if( [fmg fileExistsAtPath:savingFilePath] )
        [fmg removeItemAtPath:savingFilePath error:nil];
    [fmg createFileAtPath:savingFilePath contents:convertData attributes:nil];
}

+ (NSMutableArray *)convertMusicSheetToData:(NSData *)data
{
    NSMutableArray *tempMusicSheetArr = [[NSMutableArray alloc] init];
    GDataXMLDocument *xmlDoc;
    xmlDoc = [[GDataXMLDocument alloc] initWithData:data encoding:NSUTF8StringEncoding error:nil];
    NSArray *mSheets = [xmlDoc nodesForXPath:@"//GUITAR_SCORE/SHEET" error:nil];

    for( GDataXMLElement *mSheet in mSheets ){
        NSMutableDictionary *tempStepDic = [[NSMutableDictionary alloc] init];
        NSArray *steps = [mSheet elementsForName:@"STEP"];
        for( GDataXMLElement *step in steps ){
            NSMutableArray *tempCodes = [[NSMutableArray alloc] init];
            NSArray *codes = [step elementsForName:@"CODE"];
            for( GDataXMLElement *code in codes)
            {
                CodeInfo *tempCodeInfo = [[CodeInfo alloc] init];
                tempCodeInfo.codeName = [[code attributeForName:@"code_name"] stringValue];
                tempCodeInfo.rhythm = [[[code attributeForName:@"rhythm"] stringValue] intValue];
                [tempCodes addObject:tempCodeInfo];
            }
            [tempStepDic setObject:tempCodes forKey:[[step attributeForName:@"step_count"] stringValue]];
        }
        [tempMusicSheetArr addObject:tempStepDic];
    }
    return tempMusicSheetArr;
}

+ (NSMutableArray *)loadMusicSheet:(NSString *)mSheetName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *loadFileName;
    if( [mSheetName hasSuffix:@"cod"] )
        loadFileName = mSheetName;
    else
        loadFileName = [mSheetName stringByAppendingString:@"_Code.cod"];
    NSString *loadFilePath = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/Code/%@",loadFileName]];
    
    NSFileManager *fmg;
    NSData *readData = nil;
    
    fmg = [NSFileManager defaultManager];
    if( [fmg fileExistsAtPath:loadFilePath] ){
        readData = [fmg contentsAtPath:loadFilePath];
        if( [readData length] > 0 ){
            return [self convertMusicSheetToData:readData];
        }
    }else{
        return nil;
    }
    return nil;
}
@end
