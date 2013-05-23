//
//  HttpAsyncApi.h
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    E_REQUEST_STATE_DEFAULT = 2,
    E_REQUEST_STATE_START,
    E_REQUEST_STATE_PROGRESS,
    E_REQUEST_STATE_COMPLETE,
} enum_requestState;

@interface HttpAsyncApiRequestResult : NSObject
@property (nonatomic, strong) NSString *retString;
@property (nonatomic, strong) NSString *errorDomain;
@end

@protocol RequestObserver <NSObject>
@optional
- (void)requestFinished:(NSString *)retString;
@end

@interface HttpAsyncApi : NSObject
{
    NSURLConnection *connection;
    NSMutableData *responseData;
}
@property (nonatomic, strong) id observer;
@property NSInteger requestState;
+ (HttpAsyncApi *)getInstance;
- (void)attachObserver:(id<RequestObserver>)observer;
- (void)requestRecipe:(NSInteger)startPostIndex withEndPostIndex:(NSInteger)endPostIndex;
@end