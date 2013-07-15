//
//  HttpAsyncApi.h
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpAsyncApiRequestResult : NSObject
@property (nonatomic, strong) NSString *retString;
@property (nonatomic, strong) NSString *errorDomain;
@end

@protocol RequestObserver <NSObject>
@optional
- (void)requestFinished:(NSString *)retString;
- (void)requestFailed;
@end

@interface HttpAsyncApi : NSObject
{
    NSURLConnection *connection;
    NSMutableData *responseData;
}
@property (nonatomic, strong) id observer;
@property NSInteger requestState;
+ (HttpAsyncApi *)getInstance;
+ (HttpAsyncApi *)getInstanceComment;
+ (HttpAsyncApi *)getInstanceCommentSend;
- (void)attachObserver:(id<RequestObserver>)observer;
- (void)clearObserver;
- (void)requestRecipe:(NSInteger)numberPostIndex withOffsetPostIndex:(NSInteger)offsetPostIndex;
- (void)requestComment:(NSString *)postID;
@end