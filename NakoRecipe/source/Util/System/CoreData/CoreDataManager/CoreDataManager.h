//
//  CoreDataManager.h
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Post.h"
#import "AttatchMent.h"

@interface CoreDataManager : NSObject
{
    AppDelegate *ad;
}
+(CoreDataManager *)getInstance;
- (void)saveContext;
#pragma mark - Post
- (void)makePostFromBundle;
- (BOOL)validatePostId:(NSString *)postId;
- (void)updatePost:(NSDictionary *)jsonDict;
- (void)savePost:(NSDictionary *)jsonDict;
- (NSArray *)getPosts;
- (Post *)getPost:(NSString *)postId;
#pragma mark - Attachment
//sort
NSInteger intSortURL(AttatchMent *item1, AttatchMent *item2, void *context);
@end
