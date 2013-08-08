//
//  BlogListViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 8..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "BlogListViewController.h"

@implementation BlogListItem
@synthesize url,blog_title,blog_name,blog_desc;
@end

@interface BlogListViewController ()

@end

@implementation BlogListViewController
@synthesize blogArr,searchBaseURL,totalCount,recipeTitle;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect tempRect;
        tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 768, 40):CGRectMake(0, 0, 220, 40);
        CGFloat titleFontHeight;
        if( [UIFONT_NAME isEqualToString:@"HA-TTL"] )
            titleFontHeight = [SystemInfo isPad]?24.0:20.0f;
        else
            titleFontHeight = [SystemInfo isPad]?24.0:20.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:tempRect];
        label.font = [UIFont fontWithName:UIFONT_NAME size:titleFontHeight];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"블로그 검색 결과";
        self.navigationItem.titleView = label;
        
        tempRect = self.view.bounds;
        tempRect.size.height -= 44;
        blogTable = [[UITableView alloc] init];
        blogTable.frame = tempRect;
        blogTable.dataSource = self;
        blogTable.delegate = self;
        blogTable.backgroundColor = [CommonUI getUIColorFromHexString:@"#E8E8E8"];
        [self.view addSubview:blogTable];
        
        blogArr = [[NSMutableArray alloc] init];
        totalCount = 0;
        searchBaseURL = nil;
        webViewController = [[BlogWebViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [blogTable reloadData];
    UILabel *tempLabel = (UILabel *)self.navigationItem.titleView;
    if( recipeTitle != nil )
        tempLabel.text = [NSString stringWithFormat:@"%@ 의 블로그 검색 결과",recipeTitle];
    else
        tempLabel.text = @"블로그 검색 결과";
}

- (void)viewDidDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [blogArr count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlogListItem *tempBlogItem = [blogArr objectAtIndex:indexPath.row];
    webViewController.url = tempBlogItem.url;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTable"];
    UILabel *lblBlogName = nil;
    UILabel *lblBlogDesc = nil;
    UILabel *lblBlogTitle = nil;
    
    BlogListItem *tempBlogItem = [blogArr objectAtIndex:indexPath.row];
    CGRect tempRect;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentTable"];
        lblBlogName = [[UILabel alloc] init];
        lblBlogName.tag = 1;
        lblBlogName.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        lblBlogName.textColor = [CommonUI getUIColorFromHexString:@"3090C7"];
        lblBlogName.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblBlogName];

        lblBlogDesc = [[UILabel alloc] init];
        lblBlogDesc.tag = 2;
        lblBlogDesc.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        lblBlogDesc.textColor = [UIColor grayColor];
        lblBlogDesc.backgroundColor = [UIColor clearColor];
        lblBlogDesc.numberOfLines = 0;
        lblBlogDesc.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.contentView addSubview:lblBlogDesc];

        lblBlogTitle = [[UILabel alloc] init];
        lblBlogTitle.tag = 3;
        lblBlogTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        lblBlogTitle.textColor = [UIColor grayColor];
        lblBlogTitle.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lblBlogTitle];
        
        tempRect.origin.x = 10;
        tempRect.origin.y = 5;
        tempRect.size.width = self.view.frame.size.width -20;
        tempRect.size.height = 20;
        lblBlogTitle.frame = tempRect;
        
        tempRect.origin.x = 10;
        tempRect.origin.y = 30;
        tempRect.size.width = self.view.frame.size.width -20;
        tempRect.size.height = 20;
        lblBlogName.frame = tempRect;
        
        tempRect.origin.x = 10;
        tempRect.origin.y = 50;
        tempRect.size.width = self.view.frame.size.width -20;
        tempRect.size.height = 40;
        lblBlogDesc.frame = tempRect;
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [CommonUI getUIColorFromHexString:@"E4E3DC"];
        [cell setSelectedBackgroundView:bgColorView];
    }else{
        lblBlogName = (UILabel *)[cell viewWithTag:1];
        lblBlogDesc = (UILabel *)[cell viewWithTag:2];
        lblBlogTitle = (UILabel *)[cell viewWithTag:3];
    }
    
    lblBlogName.text = [self stringByStrippingHTML:tempBlogItem.blog_name];
    lblBlogDesc.text = [self stringByStrippingHTML:tempBlogItem.blog_desc];
    lblBlogTitle.text = [self stringByStrippingHTML: tempBlogItem.blog_title];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (NSString *)stringByStrippingHTML:(NSString *)inputString
{
    NSMutableString *outString;
    
    if (inputString)
    {
        outString = [[NSMutableString alloc] initWithString:inputString];
        
        if ([inputString length] > 0)
        {
            NSRange r;
            
            while ((r = [outString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                [outString deleteCharactersInRange:r];
            }
            while ((r = [outString rangeOfString:@"&[^;]+;" options:NSRegularExpressionSearch]).location != NSNotFound)
            {
                [outString deleteCharactersInRange:r];
            }
        }
    }
    
    return outString;
}

@end
