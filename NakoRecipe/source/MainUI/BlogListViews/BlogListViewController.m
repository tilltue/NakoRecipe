//
//  BlogListViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 8..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "BlogListViewController.h"
#import "AFHTTPRequestOperation.h"
#import "GDataXMLNode.h"

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
        tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 668, 40):CGRectMake(0, 0, 220, 40);
        CGFloat titleFontHeight;
        if( [UIFONT_NAME isEqualToString:@"HA-TTL"] )
            titleFontHeight = [SystemInfo isPad]?24.0:15.0f;
        else
            titleFontHeight = [SystemInfo isPad]?24.0:15.0f;
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
        blogTable.backgroundColor = [CommonUI getUIColorFromHexString:@"#EAEAEA"];
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
    if( currentOperation != nil ){
        [currentOperation cancel];
        currentOperation = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getValueForElemnt:(GDataXMLElement *)element withName:(NSString *)name;
{
    NSArray *arr = [element elementsForName:name];
    if( [arr count] > 0 ){
        GDataXMLElement *find = [arr objectAtIndex:0];
        return [find stringValue];
    }
    return nil;
}

- (void)moreLoad
{
    currentOperation = nil;
    if( searchBaseURL != nil ){
        NSString *searchURL = [NSString stringWithFormat:@"%@&start=%d&display=10",searchBaseURL,[blogArr count]+1];
        NSURL *url = [NSURL URLWithString:searchURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            GDataXMLDocument *xmlDoc;
            xmlDoc = [[GDataXMLDocument alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding error:nil];
            NSArray *items = [xmlDoc nodesForXPath:@"//rss/channel" error:nil];
            if( [items count] > 0 ){
                GDataXMLElement *item = [items objectAtIndex:0];
                NSString *total_count = [self getValueForElemnt:item withName:@"total"];
                if( total_count != nil ){
                    NSArray *blogItems = [item elementsForName:@"item"];
                    for( GDataXMLElement *blogItem in blogItems)
                    {
                        BlogListItem *newItem = [[BlogListItem alloc] init];
                        newItem.url = [self getValueForElemnt:blogItem withName:@"link"];
                        newItem.blog_name = [self getValueForElemnt:blogItem withName:@"bloggername"];
                        newItem.blog_title = [self getValueForElemnt:blogItem withName:@"title"];
                        newItem.blog_desc = [self getValueForElemnt:blogItem withName:@"description"];
                        [blogArr addObject:newItem];
                    }
                    [blogTable reloadData];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ;
        }];
        currentOperation = operation;
        [operation start];

    }
}


#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL loadMore = NO;
    if( totalCount > [blogArr count] )
        loadMore = YES;
    return loadMore?[blogArr count]+1:[blogArr count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL loadMore = NO;
    if( totalCount > [blogArr count] )
        loadMore = YES;
    if( loadMore && indexPath.row == [blogArr count]){
        [self moreLoad];
    }else{
        BlogListItem *tempBlogItem = [blogArr objectAtIndex:indexPath.row];
        webViewController.url = tempBlogItem.url;
        webViewController.title = tempBlogItem.blog_name;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTable"];
    UILabel *lblBlogName = nil;
    UILabel *lblBlogDesc = nil;
    UILabel *lblBlogTitle = nil;
    
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
    
    BOOL loadMore = NO;
    if( totalCount > [blogArr count] )
        loadMore = YES;
    if( loadMore && indexPath.row == [blogArr count]){
        lblBlogName.text = @"더 보기...";
        lblBlogDesc.text = @"";
        lblBlogTitle.text = @"";
    }else{
        BlogListItem *tempBlogItem = [blogArr objectAtIndex:indexPath.row];
        lblBlogName.text = [self stringByStrippingHTML:tempBlogItem.blog_name];
        lblBlogDesc.text = [self stringByStrippingHTML:tempBlogItem.blog_desc];
        lblBlogTitle.text = [self stringByStrippingHTML: tempBlogItem.blog_title];
    }
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
