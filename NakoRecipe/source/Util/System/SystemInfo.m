//
//  SystemInfo.m
//  eBookMall
//
//  Created by nako on 1/2/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "SystemInfo.h"
#include <sys/utsname.h>

#define HEIGHT_IPHONE_5 568
#define IS_PAD      ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define IS_IPHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds ].size.height == HEIGHT_IPHONE_5 )

@implementation SystemInfo

+(NSString*)modelAsString
{
    struct utsname platform;
    int rc = uname(&platform);
    if(rc == -1)
    {
        // Error...
        return nil;
    }
    else
    {
        // Convert C-string to NSString
        return [NSString stringWithCString:platform.machine encoding:NSUTF8StringEncoding];
    }
}

+(BOOL)shadowOptionModel
{
    NSString *model = [self modelAsString];
    if( model != nil ){
        NSArray *modelArr = [model componentsSeparatedByString:@","];
        if( [modelArr count] == 2){
            NSInteger subIndex = 0;
            NSString *prefixModel = [modelArr objectAtIndex:0];
            if([prefixModel rangeOfString:@"iPod"].length)
                return NO;
            subIndex = [prefixModel rangeOfString:@"iPhone"].length;
            if(subIndex){
                NSString *num = [prefixModel substringFromIndex:subIndex];
                if( num != nil && [num intValue] > 4 )
                    return YES;
                else
                    return NO;
            }
            subIndex = [prefixModel rangeOfString:@"iPad"].length;
            if(subIndex){
                NSString *num = [prefixModel substringFromIndex:subIndex];
                if( num != nil && [num intValue] > 3 )
                    return YES;
                else
                    return NO;
            }
        }
    }
    return NO;
}

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
