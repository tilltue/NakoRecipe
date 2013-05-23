//
//  HttpAsyncApi.h
//  NakoRecipe
//
//  Created by nako on 5/23/13.
//  Copyright (c) 2013 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    E_REQUEST_STATE_START = 2,
    E_REQUEST_STATE_PROGRESS,
    E_REQUEST_STATE_COMPLETE,
} enum_requestState;

@interface HttpAsyncApiRequestResult : NSObject
@property (nonatomic, retain) NSString *retString;
@property (nonatomic, retain) NSString *errorDomain;
@end


@interface HttpAsyncApi : NSObject
+ (HttpAsyncApi *)getInstance;
- (void)requestRecipe;
@end