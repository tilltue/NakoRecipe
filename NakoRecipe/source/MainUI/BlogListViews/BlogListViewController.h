//
//  BlogListViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 8..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogWebViewController.h"

@interface BlogListItem : NSObject
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *blog_title;
@property (nonatomic, strong) NSString *blog_name;
@property (nonatomic, strong) NSString *blog_desc;
@end

@interface BlogListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *blogTable;
    BlogWebViewController *webViewController;
}
@property (nonatomic, strong) NSString *searchBaseURL;
@property (nonatomic, strong) NSString *recipeTitle;
@property (nonatomic, strong) NSMutableArray *blogArr;
@property (nonatomic, assign) int totalCount;
@end
