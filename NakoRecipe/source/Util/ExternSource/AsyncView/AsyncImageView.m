//
//  AsyncImageView.m
//  eBookMall
//
//  Created by nako on 4/16/13.
//  Copyright (c) 2013 nako. All rights reserved.
//

#import "AsyncImageView.h"
#import "FileControl.h"

@implementation AsyncImageView
@synthesize uniqueDir;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        connection = nil;
        data = nil;
        loadURL = nil;
        isLoadComplete = NO;
        uniqueDir = nil;
    }
    return self;
}

- (void)loadImageFromURL:(NSString *)url withResizeWidth:(CGFloat)width
{
    connection = nil;
    data = nil;
    isLoadComplete = NO;
    resizeWidth = width;
    [self setImage:nil];
    UIImage *tempCacheImage = nil;
    if( uniqueDir == nil && (tempCacheImage = [FileControl checkCachedImage:url]) != nil ){
        [self setImage:tempCacheImage];
        isLoadComplete = YES;
        connection=nil;
        data=nil;
        return;
    }else if( uniqueDir != nil && (tempCacheImage = [FileControl checkCachedImage:url withDir:uniqueDir]) != nil){
        [self setImage:tempCacheImage];
        isLoadComplete = YES;
        connection=nil;
        data=nil;
    }
    if( isLoadComplete || [url isEqualToString:loadURL]){
    }else{
        loadURL = url;
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        connection = [[NSURLConnection alloc]
                      initWithRequest:request delegate:self];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection
{
    if( self ){
        if( [data length] > 0 && resizeWidth > 0 ){
            UIImage *tempImage = [UIImage imageWithData:data];
            CGFloat resizeHeight = (resizeWidth / (float)tempImage.size.width ) * (float)tempImage.size.height;
            tempImage = [CommonUI ImageResize:tempImage withSize:CGSizeMake(resizeWidth, resizeHeight)];
            if( uniqueDir == nil ){
                [FileControl cacheImage:[[[theConnection currentRequest] URL] absoluteString]  withImage:tempImage];
            }else{
                [FileControl cacheImage:[[[theConnection currentRequest] URL] absoluteString]  withImage:tempImage withDir:uniqueDir];
            }
            [self setImage:tempImage];
        }
        isLoadComplete = YES;
        connection=nil;
        data=nil;
    }else{
        
    }
}


@end
