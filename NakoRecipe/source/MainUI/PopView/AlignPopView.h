//
//  AlignPopView.h
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 9..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlignPopViewDelegate <NSObject>
- (void)selectAlign:(int)alignType;
@end

@interface AlignPopView : UIView <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, unsafe_unretained) id <AlignPopViewDelegate> align_delegate;
@end
