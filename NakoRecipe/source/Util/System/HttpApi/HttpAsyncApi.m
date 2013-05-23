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
#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true"

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

- (void)requestRecipe:(NSInteger)startPostIndex withEndPostIndex:(NSInteger)endPostIndex
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        //NSLog(@"Progress");
    }else{
        requestState = E_REQUEST_STATE_START;
        if( responseData == nil )
            responseData = [[NSMutableData alloc] init];
        [responseData setLength:0];
        
        NSURL * url = [[NSURL alloc] initWithString:DATA_URL];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];
        NSLog(@"Start");
    }
}

#pragma mark - Observer Pattern Methods

- (void)attachObserver:(id<RequestObserver>)addObserver
{
    self.observer = addObserver;
}

- (void)requestFinished
{
    dispatch_async( dispatch_get_main_queue(), ^{
        if( [self.observer respondsToSelector:@selector(requestFinished:)] )
            [self.observer requestFinished:[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
    });
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
}

@end
