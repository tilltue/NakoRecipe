//
//  SystemInfo.m
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "SystemInfo.h"

#define HEIGHT_IPHONE_5 568
#define IS_PAD      ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_5 )

@implementation SystemInfo

+(BOOL)isPad
{
    return IS_PAD;
}

+(BOOL)isPhone5
{
    return IS_IPHONE_5;
}

+(BOOL)isAbove5
{
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer class is used as fallback when it isn't available.
    NSString *reqSysVer = @"5.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }else {
        return NO;
    }
}

+(BOOL)isAbove6
{
    // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer class is used as fallback when it isn't available.
    NSString *reqSysVer = @"6.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
        return YES;
    }else {
        return NO;
    }
}

+(BOOL)isRetinaDisplay
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        return YES;
    } else {
        // non-Retina display
        return NO;
    }
}
+(NSString *)getAESKey
{
    return @"letsgopalaoobook";
}

+(NSString*) urlEncode:(NSString*)plainStr encodingType:(NSString*)encodeStr
{
	if ([encodeStr isEqualToString:@"EUC-KR"]) {
        NSString *ret = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)plainStr, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingEUC_KR));
		return ret;
	}else{
        NSString *ret = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)plainStr, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
		return ret;
	}
	
}

+(NSString*) urlDecode:(NSString*)plainStr encodingType:(NSString*)encodeStr
{
	if ([encodeStr isEqualToString:@"EUC-KR"]) {
		return [plainStr stringByReplacingPercentEscapesUsingEncoding:-2147481280];
	}else {
		return [plainStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
}

@end