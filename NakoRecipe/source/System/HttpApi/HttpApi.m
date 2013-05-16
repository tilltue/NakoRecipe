//
//  HttpApi.m
//  NakoRecipe
//
//  Created by nako on 5/16/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "HttpApi.h"
#define REQUEST_TIMEOUT 10
#define DATA_URL @"http://cfile216.uf.daum.net/attach/23549A3A5194D2781574FA"

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

- (NSData *)requestXML:(NSString *)url
{
    //NSLog(@"%@",url);
    NSError * error;
    NSData * xmlData;
    NSURLResponse * response;
    NSURL * surl = [NSURL URLWithString:url];
    NSURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:surl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    //NSLog(@"%@",[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding]);
    return xmlData;
}

- (NSString *)getRecipe
{
    NSData *data = [self requestXML:DATA_URL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
