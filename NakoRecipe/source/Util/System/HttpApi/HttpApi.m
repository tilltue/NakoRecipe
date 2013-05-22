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
#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true&number=100"

@implementation HttpRequestResult
@synthesize retString,errorDomain;
@end

@implementation HttpApi

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

- (BOOL)jsonError:(NSMutableDictionary *)jsonDic
{
    BOOL result = [[jsonDic objectForKey:@"error_code"] isEqualToString:@"0000"]?YES:NO;
    return result;
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

@end
