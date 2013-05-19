//
//  FileControl.m
//  eBookMall
//
//  Created by nako on 1/11/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "FileControl.h"
#include <sys/xattr.h>

#define TEMP_DIR NSTemporaryDirectory()

@implementation FileControl

+ (BOOL)checkFileExist:(NSString *)fullPath
{
    NSFileManager *fm =[NSFileManager defaultManager];
	if (![fm fileExistsAtPath:fullPath]) {
		return NO;
	}
    return YES;
}

+ (void)addSkipBackupAttributeToPath:(NSString*)path
{
    u_int8_t b = 1;
    setxattr( [ path fileSystemRepresentation ], "com.apple.MobileBackup", &b, 1, 0, 0 );
}

+ (void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
}

+ (NSString *)getStringToPath:(NSString *)path
{
    NSString *tempString = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    return tempString;
}

+ (NSData *)getDataToPath:(NSString *)path
{
    NSData *tempData = [[NSMutableData alloc] initWithContentsOfFile:path];
    return tempData;
}


+ (NSString *)getDocumentsPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

+(NSString *)getLibraryCachesPath
{
    NSArray  * paths                  = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString * libraryCachesDirectory = [ paths objectAtIndex: 0 ];
    
    return libraryCachesDirectory;
}

+ (void)createBooksDirectory {
	NSString      * docPath  = [ FileControl getDocumentsPath ];
	NSString      * booksDir = [ docPath stringByAppendingFormat: @"/books" ];
	NSFileManager * fm       = [ NSFileManager defaultManager ];
	NSError       * error;
    
	if( ![ fm fileExistsAtPath: booksDir ] )
    {
		[ fm createDirectoryAtPath: booksDir
       withIntermediateDirectories: NO
                        attributes: nil
                             error: &error ];
        
        [ FileControl addSkipBackupAttributeToPath: booksDir ];
	}
}

+ (NSString*)getBooksDirectory
{
	NSString * docPath  = [ FileControl getDocumentsPath ];
	NSString * booksDir = [ docPath stringByAppendingFormat: @"/books" ];
    
    if( ![ FileControl checkFileExist: booksDir ] )
    {
        [ FileControl createBooksDirectory ];
    }
    
	return booksDir;
}

+ (void)createDownloadsDirectory
{
	NSString      * docPath      = [ FileControl getDocumentsPath ];
	NSString      * downloadsDir = [ docPath stringByAppendingFormat: @"/downloads" ];
	NSFileManager * fm           = [ NSFileManager defaultManager ];
	NSError       * error;
    
	if( ![ fm fileExistsAtPath: downloadsDir ] )
    {
		[ fm createDirectoryAtPath: downloadsDir
       withIntermediateDirectories: NO
                        attributes: nil
                             error: &error ];
        
        [ FileControl addSkipBackupAttributeToPath: downloadsDir ];
	}
}

+ (NSString*)getDownloadsDirectory
{
	NSString *docPath = [FileControl getDocumentsPath];
	NSString *downloadsDir = [docPath stringByAppendingFormat:@"/downloads"];
	if (![FileControl checkFileExist:downloadsDir]) {
        [FileControl createDownloadsDirectory];
    }
	return downloadsDir;
}

+ (NSString *)getDownloadFilePath:(NSString *)contentID withMemberNo:(NSString *)memberNo
{
    if( contentID == nil || memberNo == nil )
        return nil;
    return [NSString stringWithFormat:@"%@/%@_%@.download",[self getDownloadsDirectory],contentID,memberNo];
}

+ (void)createEPubDirectory:(NSString *)fileName
{
	NSFileManager * fm      = [ NSFileManager defaultManager ];
	NSString      * ePubDir = [ FileControl getEPubDirectory: fileName ];
	NSError       * error;
    
	if( ![ fm fileExistsAtPath: ePubDir ] )
    {
		[ fm createDirectoryAtPath: ePubDir
       withIntermediateDirectories: NO
                        attributes: nil
                             error: &error ];
	}
}

+ (NSString*)getEPubDirectory:(NSString*)fileName {
    NSString * fileNameWithoutExt = [ fileName stringByDeletingPathExtension ];
    
    int offset = [ fileName length ] - [ fileNameWithoutExt length ];
    
    NSString *pureName = [fileName substringToIndex:[fileName length] - offset ];
	NSString *booksDir = [FileControl getBooksDirectory];
	NSString *ePubDir = [booksDir stringByAppendingPathComponent:pureName];
    
	return ePubDir;
}

+ (NSInteger)getFileLength:(NSString *)filePath
{
    NSFileManager * fm      = [ NSFileManager defaultManager ];
    NSInteger fileLength = 0;
    NSError       * error;
    if([FileControl checkFileExist:filePath]){
        NSDictionary *fileAttr = [fm attributesOfItemAtPath:filePath error:&error];
        fileLength = [fileAttr fileSize];
    }
    return fileLength;
}

+ (void)removeFile:(NSString*)path
{
    NSFileManager *fm =[NSFileManager defaultManager];
	if (![fm fileExistsAtPath:path]) {
		return;
	}
	NSError *error;
	[fm removeItemAtPath:path error:&error];
}

+ (NSString *)createDrmDecryptFile:(NSString *)fileName
{
    NSFileManager * fm      = [ NSFileManager defaultManager ];
	NSString      * drmDecryptFilePath = [[self getDownloadsDirectory] stringByAppendingFormat:@"/decryptDRM%@",fileName];
    
	if( ![ fm fileExistsAtPath: drmDecryptFilePath ] )
    {
		[ fm createFileAtPath:drmDecryptFilePath
                     contents:nil
                   attributes:nil
         ];
	}
    return drmDecryptFilePath;
}

+ (NSString *)getDownloadImagePath:(NSString *)contentID withMemberNo:(NSString *)memberNo withCoverUrl:(NSString *)coverUrl
{
    NSString *downloadFilePath = [FileControl getDownloadFilePath:contentID withMemberNo:memberNo];
    NSString *installFileName = [[downloadFilePath lastPathComponent] stringByDeletingPathExtension];
    NSString *installFilePath = [FileControl getEPubDirectory:installFileName];
    NSString *downloadImagePath = [installFilePath stringByAppendingFormat:@"/%@%@.%@",contentID,memberNo,[coverUrl pathExtension]];
    if( [self checkFileExist:downloadImagePath] ){
        return downloadImagePath;
    }else{
        //        [InstallBook downloadCoverImage:contentID withMemberNo:memberNo withCoverUrl:coverUrl];
        return nil;
    }
}

+ (void)cacheImageToURL:(NSString *)imageURLString
{
    NSURL *ImageURL = [[NSURL alloc] initWithString:imageURLString];
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [imageURLString lastPathComponent];
    NSString *uniquePath = [TEMP_DIR stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if( ![[NSFileManager defaultManager] fileExistsAtPath: uniquePath] ){
        // The file doesn't exist, we should get a copy of it
        
        // Fetch image
        NSData *data = [[NSData alloc] initWithContentsOfURL: ImageURL];
        UIImage *image = [[UIImage alloc] initWithData: data];
        
        // Is it PNG or JPG/JPEG?
        // Running the image representation function writes the data from the image to a file
        if( [imageURLString rangeOfString:@".png" options: NSCaseInsensitiveSearch].location != NSNotFound ){
            
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
            
        }else if([imageURLString rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                 [imageURLString rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound ){
            
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
}

+ (void)cacheImage:(NSString *)imageURL withImage:(UIImage *)image
{
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [imageURL lastPathComponent];
    NSString *uniquePath = [TEMP_DIR stringByAppendingPathComponent: filename];
    
    // Check for file existence
    if( ![[NSFileManager defaultManager] fileExistsAtPath: uniquePath] ){
        if( [imageURL rangeOfString:@".png" options: NSCaseInsensitiveSearch].location != NSNotFound ){
            
            [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
            
        }else if([imageURL rangeOfString: @".jpg" options: NSCaseInsensitiveSearch].location != NSNotFound ||
                 [imageURL rangeOfString: @".jpeg" options: NSCaseInsensitiveSearch].location != NSNotFound ){
            
            [UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
        }
    }
}



+ (UIImage *)getCachedImage:(NSString *)imageURLString
{
    NSString *filename = [imageURLString lastPathComponent];
    NSString *uniquePath = [TEMP_DIR stringByAppendingPathComponent: filename];
    
    UIImage *image;
    
    // Check for a cached version
    if( [[NSFileManager defaultManager] fileExistsAtPath: uniquePath] ){
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }else{
        // get a new one
        [self cacheImageToURL: imageURLString];
        image = [UIImage imageWithContentsOfFile: uniquePath];
    }
    return image;
}

+ (UIImage *)checkCachedImage:(NSString *)imageURLString
{
    NSString *filename = [imageURLString lastPathComponent];
    NSString *uniquePath = [TEMP_DIR stringByAppendingPathComponent: filename];
    
    UIImage *image;
    
    // Check for a cached version
    if( [[NSFileManager defaultManager] fileExistsAtPath: uniquePath] ){
        image = [UIImage imageWithContentsOfFile: uniquePath]; // this is the cached image
    }else{
        return nil;
    }
    return image;
}

+ (NSArray *)getAllImageFileList:(NSString *)rootDir
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:rootDir error:nil];
    NSMutableArray *fileList = [[NSMutableArray alloc] init];
    for( NSString *dir in dirContents )
    {
        NSString *path = [rootDir stringByAppendingPathComponent:dir];
        BOOL isDir = NO;
        [fm fileExistsAtPath:path isDirectory:(&isDir)];
        if(!isDir) {
            NSString *fileName = [path lastPathComponent];
            if( [fileName hasSuffix:@"jpg"] || [fileName hasSuffix:@"png"] ){
                [fileList addObject:path];
            }
        }else{
            [fileList addObjectsFromArray:[self getAllImageFileList:path]];
        }
    }
    return fileList;
}
@end
