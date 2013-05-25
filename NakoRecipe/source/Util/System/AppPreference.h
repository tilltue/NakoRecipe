//
//  AppPreference.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 25..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>
#define PREKEY_DEVICEID             @"prekey_deviceid"
#define PREKEY_UPDATE_RECIPE        @"prekey_update_recipe"

@interface AppPreference : NSObject
+ (NSString *)getDeviceID;
+ (BOOL)setCheckTime:(NSString *)timeInterval1960 withKey:(NSString *)checkKey;
+ (NSString *)getCheckTime:(NSString *)checkKey;
@end
