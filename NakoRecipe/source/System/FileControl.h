//
//  FileControl.h
//  guitarNako
//
//  Created by nako on 10/30/12.
//  Copyright (c) 2012 nako. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileControl : NSObject
+ (void)saveMusicSheet:(NSString *)mSheetName withCodeInfoArrayInMusicSheet:(NSMutableArray *)codeInfoInMusicSheet;
+ (NSMutableArray *)loadMusicSheet:(NSString *)mSheetName;
+ (NSMutableArray *)getListScoreFile;
@end
