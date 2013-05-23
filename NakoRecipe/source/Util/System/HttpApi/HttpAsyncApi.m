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
#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true&number=100"

@implementation HttpAsyncApiRequestResult
@synthesize retString,errorDomain;
@end


@implementation HttpAsyncApi
+ (HttpAsyncApi *)getInstance
{
    static dispatch_once_t onceToken;
    static HttpAsyncApi * singletonInstance   = nil;;
    
    dispatch_once( &onceToken,
                  ^{
                      if( singletonInstance == nil )
                      {
                          singletonInstance = [ [ HttpAsyncApi alloc ] init ];
                      }
                  });
    
    return singletonInstance;
}

- (void)requestRecipe
{
    
}

#pragma mark - conncection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
   
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
}

@end
