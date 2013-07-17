//
//  AppPreference.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 25..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "AppPreference.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AppPreference

+ (NSString *)getDeviceID
{
    NSString * deviceID = [[NSUserDefaults standardUserDefaults] stringForKey:PREKEY_DEVICEID];
    if (deviceID == nil) {
        NSString * uuid = [self getUUID];
        deviceID = [self md5:uuid];
    }
    return deviceID;
}

+ (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
			result[0],  result[1], result[2],  result[3],
			result[4],  result[5], result[6],  result[7],
            result[8],  result[9], result[10],  result[11],
			result[12],  result[13], result[14],  result[15]];
    
}

+ (NSString *)getUUID
{
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"uniqueID"];
    if (!UUID)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"uniqueID"];
    }
    return UUID;
}

+ (void)setValid:(NSString *)boolString
{
    [[NSUserDefaults standardUserDefaults] setObject:boolString forKey:APP_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getValid
{
    return YES;
    NSString *retString = [[NSUserDefaults standardUserDefaults] stringForKey:APP_VERSION];
    if( retString == nil )
        return NO;
    if( [retString isEqualToString:@"YES"])
        return YES;
    return NO;
}

#pragma mark - checkin time

+ (BOOL)setCheckTime:(NSString *)timeInterval1960 withKey:(NSString *)checkKey
{
    [[NSUserDefaults standardUserDefaults] setObject:timeInterval1960 forKey:checkKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getCheckTime:(NSString *)checkKey
{
    NSString *retString = [[NSUserDefaults standardUserDefaults] stringForKey:checkKey];
    if( retString == nil )
        return @"-1";
    return retString;
}

@end
