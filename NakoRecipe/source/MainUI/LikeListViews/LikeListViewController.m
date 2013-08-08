//
//  LikeListViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 7. 20..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "LikeListViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@interface LikeListViewController ()

@end

@implementation LikeListViewController
@synthesize likeArr = _likeArr;
@synthesize requestConnection = _requestConnection;

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
        label.text = @"이 레시피를 좋아해요!";
        self.navigationItem.titleView = label;
        
        tempRect = self.view.bounds;
        tempRect.size.height -= 44;
        likeTable = [[UITableView alloc] init];
        likeTable.frame = tempRect;
        likeTable.dataSource = self;
        likeTable.delegate = self;
        likeTable.backgroundColor = [CommonUI getUIColorFromHexString:@"#E8E8E8"];
        [self.view addSubview:likeTable];
        
        _likeArr = [[NSMutableArray alloc] init];
        likeNameDict =[[NSMutableDictionary alloc] init];
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
    [likeTable reloadData];
    
    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
    for( int i = 0; i < [_likeArr count]; i++ )
    {
        NSString *fbid = [_likeArr objectAtIndex:i];
        FBRequestHandler handler =
        ^(FBRequestConnection *connection, id result, NSError *error) {
            [self requestCompleted:connection forFbID:fbid result:result error:error withIndex:i];
        };
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:fbid];        
        [newConnection addRequest:request completionHandler:handler];
    }
    [_requestConnection cancel];
    _requestConnection = newConnection;
    [newConnection start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_requestConnection cancel];
    [likeNameDict removeAllObjects];
    [_likeArr removeAllObjects];
    [likeTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestCompleted:(FBRequestConnection *)connection
                 forFbID:fbID
                  result:(id)result
                   error:(NSError *)error
               withIndex:(NSInteger)index{
    if (self.requestConnection &&
        connection != self.requestConnection) {
        return;
    }

    self.requestConnection = nil;
    
    UITableViewCell *cell = [likeTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSString *text;
    UILabel *usernameLabel = nil;
    usernameLabel = (UILabel *)[cell viewWithTag:2];
    if (error) {
        text = error.localizedDescription;
        usernameLabel.text = @"";
    } else {
        NSDictionary *dictionary = (NSDictionary *)result;
        text = (NSString *)[dictionary objectForKey:@"name"];
        usernameLabel.text = text;
        [likeNameDict setObject:text forKey:fbID];
        [likeTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:NO];
    }
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_likeArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentTable"];
    UIImageView *userThumb = nil;
    UILabel *usernameLabel = nil;
    CGRect tempRect;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentTable"];
        userThumb = [[UIImageView alloc] init];
        userThumb.tag = 1;
        userThumb.clipsToBounds = YES;
        userThumb.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:userThumb];
        
        usernameLabel = [[UILabel alloc] init];
        usernameLabel.tag = 2;
        usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        usernameLabel.textColor = [CommonUI getUIColorFromHexString:@"3090C7"];
        usernameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usernameLabel];
    }else{
        userThumb = (UIImageView *)[cell viewWithTag:1];
        usernameLabel = (UILabel *)[cell viewWithTag:2];
    }
    
    [userThumb setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",[_likeArr objectAtIndex:indexPath.row]]] placeholderImage:[UIImage imageNamed:@"ic_blank_profile"]];
    
    tempRect.origin.x = 55;
    tempRect.origin.y = 5;
    tempRect.size.width = 250;
    tempRect.size.height = 40;
    usernameLabel.frame = tempRect;
    
    tempRect.origin.x = 5;
    tempRect.origin.y = 5;
    tempRect.size.width = 40;
    tempRect.size.height = 40;
    userThumb.layer.cornerRadius = 5;
    userThumb.layer.masksToBounds = YES;
    userThumb.frame = tempRect;
    
    NSString *fbid = [_likeArr objectAtIndex:indexPath.row];
    if( [likeNameDict objectForKey:fbid] != nil )
        usernameLabel.text = [likeNameDict objectForKey:fbid];
    else
        usernameLabel.text = @"";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


@end
