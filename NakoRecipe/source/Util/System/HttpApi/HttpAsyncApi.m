//
//  HttpAsyncApi.m
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "HttpAsyncApi.h"
#import "SBJson.h"
#define REQUEST_TIMEOUT 10
//#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true"
#define DATA_URL @"http://14.63.219.181/?json=1"
#define COMMENT_URL @"http://14.63.219.181:3000/comment/load/"
@implementation HttpAsyncApiRequestResult
@synthesize retString,errorDomain;
@end


@implementation HttpAsyncApi
@synthesize observer,requestState;

+ (HttpAsyncApi *)getInstance
{
    static dispatch_once_t onceToken;
    static HttpAsyncApi * singletonInstance   = nil;;
    
    dispatch_once( &onceToken,
                  ^{
                      if( singletonInstance == nil )
                      {
                          singletonInstance = [ [ HttpAsyncApi alloc ] init ];
                          singletonInstance.requestState = E_REQUEST_STATE_DEFAULT;
                      }
                  });
    
    return singletonInstance;
}

+ (HttpAsyncApi *)getInstanceComment
{
    static dispatch_once_t onceTokenComment;
    static HttpAsyncApi * singletonInstanceComment   = nil;;
    
    dispatch_once( &onceTokenComment,
                  ^{
                      if( singletonInstanceComment == nil )
                      {
                          singletonInstanceComment = [ [ HttpAsyncApi alloc ] init ];
                          singletonInstanceComment.requestState = E_REQUEST_STATE_DEFAULT;
                      }
                  });
    
    return singletonInstanceComment;
}

+ (HttpAsyncApi *)getInstanceCommentSend
{
    static dispatch_once_t onceTokenCommentSend;
    static HttpAsyncApi * singletonInstanceCommentSend   = nil;;
    
    dispatch_once( &onceTokenCommentSend,
                  ^{
                      if( singletonInstanceCommentSend == nil )
                      {
                          singletonInstanceCommentSend = [ [ HttpAsyncApi alloc ] init ];
                          singletonInstanceCommentSend.requestState = E_REQUEST_STATE_DEFAULT;
                      }
                  });
    
    return singletonInstanceCommentSend;
}


- (void)requestRecipe:(NSInteger)numberPostIndex withOffsetPostIndex:(NSInteger)offsetPostIndex
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        //NSLog(@"Progress");
    }else{
        requestState = E_REQUEST_STATE_START;
        if( responseData == nil )
            responseData = [[NSMutableData alloc] init];
        [responseData setLength:0];
        NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@&count=%d",DATA_URL,numberPostIndex]];
        //NSLog(@"%@",[url absoluteString]);
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
        NSLog(@"Start");
    }
}

- (void)requestComment:(NSString *)postID
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        NSLog(@"Connection Cancel");
        [connection cancel];
    }else{
        requestState = E_REQUEST_STATE_START;
        if( responseData == nil )
            responseData = [[NSMutableData alloc] init];
        [responseData setLength:0];
        NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@",COMMENT_URL,postID]];
        //NSLog(@"%@",[url absoluteString]);
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
        NSLog(@"Start comment");
    }
}

#pragma mark - Observer Pattern Methods

- (void)attachObserver:(id<RequestObserver>)addObserver
{
    self.observer = addObserver;
}

- (void)clearObserver
{
    [connection cancel];
    self.observer = nil;
}

- (void)requestFinished
{
    //dispatch_async( dispatch_get_main_queue(), ^{
        if( [self.observer respondsToSelector:@selector(requestFinished:)] )
            [self.observer requestFinished:[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
    //});
}

- (void)requestFailed
{
    //dispatch_async( dispatch_get_main_queue(), ^{
        if( [self.observer respondsToSelector:@selector(requestFailed)] )
            [self.observer requestFailed];
    //});
}

#pragma mark - conncection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    requestState = E_REQUEST_STATE_PROGRESS;
    //NSLog(@"%@",[aResponse debugDescription]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    //NSLog(@"%@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    requestState = E_REQUEST_STATE_PROGRESS;
    if( responseData != nil )
        [responseData appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"finish");
    NSLog(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    requestState = E_REQUEST_STATE_COMPLETE;
    [self requestFinished];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    requestState = E_REQUEST_STATE_COMPLETE;
    NSLog(@"failed");
    [self requestFailed];
}

@end
