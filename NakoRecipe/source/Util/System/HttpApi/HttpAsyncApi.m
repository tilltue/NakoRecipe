//
//  HttpAsyncApi.m
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import "HttpAsyncApi.h"
#define REQUEST_TIMEOUT 10
//#define DATA_URL @"https://public-api.wordpress.com/rest/v1/sites/14.63.219.181/posts/?pretty=true"
#define DATA_URL @"http://14.63.219.181/?json=1"
#define COMMENT_URL @"http://14.63.219.181:3000"
@implementation HttpAsyncApiRequestResult
@synthesize retString,errorDomain;
@end


@implementation HttpAsyncApi
@synthesize observer,requestState;
@synthesize kindOfRequest = _kindOfRequest;

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
                          singletonInstance.kindOfRequest = E_REQUEST_RECIPE;
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
                          singletonInstanceComment.kindOfRequest = E_REQUEST_COMMENT;
                      }
                  });
    
    return singletonInstanceComment;
}

+ (HttpAsyncApi *)getInstanceLike
{
    static dispatch_once_t onceTokenLike;
    static HttpAsyncApi * singletonInstanceLike   = nil;;
    
    dispatch_once( &onceTokenLike,
                  ^{
                      if( singletonInstanceLike == nil )
                      {
                          singletonInstanceLike = [ [ HttpAsyncApi alloc ] init ];
                          singletonInstanceLike.requestState = E_REQUEST_STATE_DEFAULT;
                          singletonInstanceLike.kindOfRequest = E_REQUEST_LIKE;
                      }
                  });
    
    return singletonInstanceLike;
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
                          singletonInstanceCommentSend.kindOfRequest = E_REQUEST_COMMENT_SEND;
                      }
                  });
    
    return singletonInstanceCommentSend;
}

+ (HttpAsyncApi *)getInstanceLikeSend
{
    static dispatch_once_t onceTokenLikeSend;
    static HttpAsyncApi * singletonInstanceLikeSend   = nil;;
    
    dispatch_once( &onceTokenLikeSend,
                  ^{
                      if( singletonInstanceLikeSend == nil )
                      {
                          singletonInstanceLikeSend = [ [ HttpAsyncApi alloc ] init ];
                          singletonInstanceLikeSend.requestState = E_REQUEST_STATE_DEFAULT;
                          singletonInstanceLikeSend.kindOfRequest = E_REQUEST_LIKE_SEND;
                      }
                  });
    
    return singletonInstanceLikeSend;
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
        //NSLog(@"Connection Cancel");
        [connection cancel];
        //NSLog(@"ReStart comment");
    }else{
        //NSLog(@"Start comment");
    }
    requestState = E_REQUEST_STATE_START;
    if( responseData == nil )
        responseData = [[NSMutableData alloc] init];
    [responseData setLength:0];
    NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/comment/load/%@",COMMENT_URL,postID]];
    //NSLog(@"%@",[url absoluteString]);
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)requestLike:(NSString *)postID
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        //NSLog(@"Connection Cancel");
        [connection cancel];
        //NSLog(@"ReStart like");
    }else{
        //NSLog(@"Start like");
    }
    requestState = E_REQUEST_STATE_START;
    if( responseData == nil )
        responseData = [[NSMutableData alloc] init];
    [responseData setLength:0];
    NSURL * url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/like/%@",COMMENT_URL,postID]];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

- (void)sendComment:(NSDictionary *)dict
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        //NSLog(@"Connection Cancel");
        [connection cancel];
        //NSLog(@"ReStart comment send");
    }else{
        //NSLog(@"Start comment send");
    }
    requestState = E_REQUEST_STATE_START;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	
    NSString *param = @"";
    for( NSString *key in [dict allKeys])
    {
        NSString *value = [dict objectForKey:key];
        param = [param stringByAppendingFormat:@"%@=%@&",key,value];
    }
	NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/comment/write",COMMENT_URL]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)sendLike:(NSDictionary *)dict withLikeState:(BOOL)like
{
    if( requestState == E_REQUEST_STATE_PROGRESS || requestState == E_REQUEST_STATE_START ){
        //NSLog(@"Connection Cancel");
        [connection cancel];
        //NSLog(@"ReStart comment send");
    }else{
        //NSLog(@"Start comment send");
    }
    requestState = E_REQUEST_STATE_START;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	
    NSString *param = @"";
    for( NSString *key in [dict allKeys])
    {
        NSString *value = [dict objectForKey:key];
        param = [param stringByAppendingFormat:@"%@=%@&",key,value];
    }
	NSData *postData = [param dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    if( like ){
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/like",COMMENT_URL]]];
    }else{
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/unlike",COMMENT_URL]]];
    }
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	[NSURLConnection connectionWithRequest:request delegate:self];
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
    if( [self.observer respondsToSelector:@selector(requestFinished:withInstance:)] )
        [self.observer requestFinished:[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] withInstance:self];
}

- (void)requestFailed
{
    if( [self.observer respondsToSelector:@selector(requestFailed:)] )
        [self.observer requestFailed:self];
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
