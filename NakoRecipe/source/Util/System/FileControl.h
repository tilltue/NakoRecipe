//
//  FileControl.h
//  eBookMall
//
//  Created by nako on 1/11/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileControl : NSObject
+ (void)addSkipBackupAttributeToPath:(NSString*)path;
+ (void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+ (NSString *)getStringToPath:(NSString *)path;
+ (NSData *)getDataToPath:(NSString *)path;

+ (NSString *)getDocumentsPath;
+ (NSString *)getLibraryCachesPath;
+ (void)createBooksDirectory;
+ (NSString*)getBooksDirectory;
+ (void)createDownloadsDirectory;
+ (NSString*)getDownloadsDirectory;
+ (void)createEPubDirectory:(NSString *)fileName;
+ (NSString*)getEPubDirectory:(NSString*)fileName;
+ (NSString *)getDownloadFilePath:(NSString *)contentID withMemberNo:(NSString *)memberNo;
+ (BOOL)checkFileExist:(NSString *)fullPath;
+ (NSInteger)getFileLength:(NSString *)filePath;
+ (void)removeFile:(NSString*)path;
+ (NSString *)createDrmDecryptFile:(NSString *)fileName;
+ (NSString *)getDownloadImagePath:(NSString *)contentID withMemberNo:(NSString *)memberNo withCoverUrl:(NSString *)coverUrl;
+ (void)cacheImage:(NSString *)imageURL withImage:(UIImage *)image withDir:(NSString *)dirName;
+ (void)cacheImage:(NSString *)imageURL withImage:(UIImage *)image;
+ (UIImage *)getCachedImage:(NSString *)imageURLString;
+ (UIImage *)checkCachedImage:(NSString *)imageURLString withDir:(NSString *)dirName;
+ (UIImage *)checkCachedImage:(NSString *)imageURLString;
+ (NSArray *)getAllImageFileList:(NSString *)rootDir;
@end
