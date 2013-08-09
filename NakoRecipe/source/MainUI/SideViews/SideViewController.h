//
//  SideViewController.h
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 9..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *sideTable;
}
- (void)reloadTable;
@end
