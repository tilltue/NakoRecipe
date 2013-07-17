//
//  HttpAsyncApi.h
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpAsyncApi;

@interface HttpAsyncApiRequestResult : NSObject
@property (nonatomic, strong) NSString *retString;
@property (nonatomic, strong) NSString *errorDomain;
@end

@protocol RequestObserver <NSObject>
@optional
- (void)requestFinished:(NSString *)retString withInstance:(HttpAsyncApi *)instance;
- (void)requestFailed:(HttpAsyncApi *)instance;;
@end

@interface HttpAsyncApi : NSObject
{
    NSURLConnection *connection;
    NSMutableData *responseData;
}
@property (nonatomic, strong) id observer;
@property NSInteger requestState;
@property NSInteger kindOfRequest;
+ (HttpAsyncApi *)getInstance;
+ (HttpAsyncApi *)getInstanceComment;
+ (HttpAsyncApi *)getInstanceLike;
+ (HttpAsyncApi *)getInstanceCommentSend;
+ (HttpAsyncApi *)getInstanceLikeSend;
- (void)attachObserver:(id<RequestObserver>)observer;
- (void)clearObserver;
- (void)requestRecipe:(NSInteger)numberPostIndex withOffsetPostIndex:(NSInteger)offsetPostIndex;
- (void)requestComment:(NSString *)postID;
- (void)requestLike:(NSString *)postID;
- (void)sendComment:(NSDictionary *)dict;
- (void)sendLike:(NSDictionary *)dict withLikeState:(BOOL)like;
@end