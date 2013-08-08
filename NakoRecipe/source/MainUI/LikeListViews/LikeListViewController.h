//
//  LikeListViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 7. 20..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LikeListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *likeTable;
    NSMutableDictionary *likeNameDict;
}
@property (nonatomic, strong) NSMutableArray *likeArr;
@property (nonatomic, strong) FBRequestConnection *requestConnection;
@end
