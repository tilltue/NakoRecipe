//
//  AlignPopView.m
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 9..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "AlignPopView.h"
#import <QuartzCore/QuartzCore.h>
@implementation AlignPopView
@synthesize align_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

        UIButton *btnClose = [[UIButton alloc] initWithFrame:frame];
        [btnClose addTarget:self action:@selector(btnClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnClose];
        
        CGRect rect;
        rect = CGRectMake(self.frame.size.width - 90, 5, 80, 160);
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.frame = rect;
        tableView.layer.cornerRadius = 5;
        if( [SystemInfo shadowOptionModel]){
            tableView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
            tableView.layer.shadowRadius = 2;
            tableView.layer.shadowOpacity = 0.2;
        }
        [self addSubview:tableView];
    }
    return self;
}

- (void)btnClose
{
    self.hidden = YES;
}


#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self align_delegate] selectAlign:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alignTable"];
    UILabel *alignLabel = nil;
    NSArray *textArr = [NSArray arrayWithObjects:@"최신순",@"조회순",@"좋아요순",@"댓글순", nil];
    CGRect rect  = CGRectZero;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alignTable"];
        
        rect.origin.x = 10;
        rect.size = CGSizeMake(60, 40);
        alignLabel = [[UILabel alloc] init];
        alignLabel.tag = 2;
        alignLabel.font = [UIFont systemFontOfSize:15];
        alignLabel.textColor = [UIColor darkGrayColor];
        alignLabel.backgroundColor = [UIColor clearColor];
        alignLabel.frame = rect;
        [cell.contentView addSubview:alignLabel];
    }else{
        alignLabel = (UILabel *)[cell viewWithTag:2];
    }
    alignLabel.text = [textArr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

@end
