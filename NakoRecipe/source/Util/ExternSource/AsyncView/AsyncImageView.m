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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        connection = nil;
        data = nil;
        loadURL = nil;
        isLoadComplete = NO;
    }
    return self;
}

- (void)loadImageFromURL:(NSString *)url
{
    connection = nil;
    data = nil;
    isLoadComplete = NO;
    [self setImage:nil];
    UIImage *tempCacheImage = nil;
    if( (tempCacheImage = [FileControl checkCachedImage:url]) != nil ){
        [self setImage:tempCacheImage];
        isLoadComplete = YES;
        connection=nil;
        data=nil;
        return;
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
        if( [data length] > 0 ){
            [FileControl cacheImage:[[[theConnection currentRequest] URL] absoluteString]  withImage:[UIImage imageWithData:data]];
            [self setImage:[UIImage imageWithData:data]];
        }
        isLoadComplete = YES;
        connection=nil;
        data=nil;
    }else{
        
    }
}


@end
