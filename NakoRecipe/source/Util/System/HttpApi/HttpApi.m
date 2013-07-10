//
//  HttpApi.m
//  NakoRecipe
//
//  Created by nako on 5/16/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "HttpApi.h"
#import "CoreDataManager.h"
#import "SBJson.h"

#define REQUEST_TIMEOUT 10
#define VERSION_URL @"https://dl.dropboxusercontent.com/s/8qep15t65a0mfy2/version.txt"
#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true&number=100"

@implementation HttpRequestResult
@synthesize retString,errorDomain;
@end

@implementation HttpApi
@synthesize requestState;

+ (HttpApi *)getInstance
{
    static dispatch_once_t onceToken;
    static HttpApi * singletonInstance   = nil;;
    
    dispatch_once( &onceToken,
                  ^{
                      if( singletonInstance == nil )
                      {
                          singletonInstance = [ [ HttpApi alloc ] init ];
                      }
                  });
    
    return singletonInstance;
}

- (HttpRequestResult *)requestJSON:(NSString *)url
{
//    NSLog(@"%@",url);
    HttpRequestResult *tempResult = [[HttpRequestResult alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData *xmlData;
    NSURLResponse * response;
    NSURL * surl = [NSURL URLWithString:url];
    NSURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:surl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (error.code < 0) {
        tempResult.errorDomain = @"NETWORK_ERROR";
        return tempResult;
    }
    NSString *jsonString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",jsonString);
    tempResult.retString = [[NSString alloc] initWithString:jsonString];
    if( error.domain != nil )
        tempResult.errorDomain = [[NSString alloc] initWithString:error.domain];
    else
        tempResult.errorDomain = nil;
    return tempResult;
}

- (BOOL)requestVersion
{
    if( [AppPreference getValid] )
        return YES;
    if( requestState == E_REQUEST_STATE_PROGRESS )
        return NO;
    if( responseData == nil )
        responseData = [[NSMutableData alloc] init];
    [responseData setLength:0];
    NSURL * url = [[NSURL alloc] initWithString:VERSION_URL];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    requestState = E_REQUEST_STATE_PROGRESS;
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    return NO;
}

- (NSString *)getRecipe
{
    HttpRequestResult *ret = [self requestJSON:DATA_URL];
    if( ret.errorDomain == nil ){
        NSMutableDictionary* dict = [[[SBJsonParser alloc] init] objectWithString:ret.retString];
        NSString *found = [dict objectForKey:@"found"];
        if( [found intValue] > 0 ){
            //NSLog(@"fonund %d",[found intValue]);
            NSArray *postDictArr = [dict objectForKey:@"posts"];
            for( NSMutableDictionary *postDict in postDictArr )
            {
                if( [postDict objectForKey:@"ID"] != nil )
                   [[CoreDataManager getInstance] savePost:postDict];
            }
        }
    }
    return ret.retString;
}

#pragma mark - conncection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    requestState = E_REQUEST_STATE_PROGRESS;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    requestState = E_REQUEST_STATE_PROGRESS;
    if( responseData != nil )
        [responseData appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    requestState = E_REQUEST_STATE_COMPLETE;
    NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"complete %@",jsonString);
    if( [jsonString intValue] > 103 ){
        [AppPreference setValid:@"YES"];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    requestState = E_REQUEST_STATE_DEFAULT;
}


@end
