//
//  SystemInfo.h
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SystemInfo : NSObject
+(BOOL)isPad;
+(BOOL)isPhone5;
+(BOOL)isAbove5;
+(BOOL)isAbove6;
+(BOOL)isRetinaDisplay;
+(NSString *)getAESKey;
+(NSString*) urlEncode:(NSString*)plainStr encodingType:(NSString*)encodeStr;
+(NSString*) urlDecode:(NSString*)plainStr encodingType:(NSString*)encodeStr;
@end
