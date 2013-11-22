//
//  SideViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 8. 9..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "SideViewController.h"
#import "AppDelegate.h"
#import "KakaoLinkCenter.h"

@interface SideViewController ()

@end

@implementation SideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect rect = self.view.bounds;
        rect.origin.y = 20;
        rect.size.width = [SystemInfo isPad]?350:250;
        rect.size.height = 260;
        sideTable = [[UITableView alloc] init];
        sideTable.frame = rect;
        sideTable.backgroundColor = [UIColor clearColor];
        sideTable.dataSource = self;
        sideTable.delegate = self;
        sideTable.scrollEnabled = NO;
        sideTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:sideTable];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.view.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [sideTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable
{
    [sideTable reloadData];
}

#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 ){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if( [appDelegate loginCheck] ){
            [appDelegate facebookLogout];
            [[LocalyticsSession shared] tagEvent:@"Facebook Logout"];
        }else{
            [appDelegate openSession];
            [[LocalyticsSession shared] tagEvent:@"Facebook Login"];
        }
    }else{
        NSMutableArray *metaInfoArray = [NSMutableArray array];
        
        NSDictionary *metaInfoAndroid = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"android", @"os",
                                         @"phone", @"devicetype",
                                         @"market://details?id=com.bulgogi.recipe", @"installurl",
                                         @"example://example", @"executeurl",
                                         nil];
        
        NSDictionary *metaInfoIOS = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ios", @"os",
                                     @"phone", @"devicetype",
                                     @"http://itunes.apple.com/app/id657294564?mt=8", @"installurl",
                                     @"example://example", @"executeurl",
                                     nil];
        
        [metaInfoArray addObject:metaInfoAndroid];
        [metaInfoArray addObject:metaInfoIOS];
        
        [KakaoLinkCenter openKakaoAppLinkWithMessage:@"진격의 야간매점 레시피! 해피투게더 야간매점에서 소개하는 다양한 레시피로 홈메이드 스타일 푸드를 즐겨보세요"
                                                 URL:@"http://link.kakao.com/?test-ios-app"
                                         appBundleID:[[NSBundle mainBundle] bundleIdentifier]
                                          appVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                             appName:@"야간매점 레시피"
                                       metaInfoArray:metaInfoArray];
    }
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 39;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectZero;
    rect.size.width = tableView.frame.size.width;
    rect.size.height = 30;
    UIView *sectionHeader = [[UIView alloc] init];
    sectionHeader.frame = rect;
    sectionHeader.backgroundColor = [UIColor clearColor];
    
    rect.origin.x = 15;
    rect.origin.y = 15;
    rect.size.width = tableView.frame.size.width - 30;
    rect.size.height = 20;
    
    UILabel *sectionLabel = [[UILabel alloc] init];
    sectionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:[SystemInfo isPad]?20:17];
    sectionLabel.textColor = [CommonUI getUIColorFromHexString:@"41B1B5"];
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.frame = rect;
    [sectionHeader addSubview:sectionLabel];
    
    rect.origin.x = 15;
    rect.origin.y = 37;
    rect.size.width = tableView.frame.size.width -30;
    rect.size.height = 2;
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [CommonUI getUIColorFromHexString:@"41B1B5"];
    lineView.frame = rect;
    [sectionHeader addSubview:lineView];
    
    if( section == 0 ){
        sectionLabel.text = @" 계정";
    }else{
        sectionLabel.text = @" 설정";
    }
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    CGRect rect = CGRectZero;
    if( indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:@"AccountTableCell"];
        UIImageView *faceBookIcon = nil;
        UILabel *facebookLoginLabel = nil;
        UILabel *messageLabel = nil;
        UILabel *facebookNameLabel = nil;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AccountTableCell"];
            rect.origin.x = 25;
            rect.origin.y = 20;
            rect.size = CGSizeMake(32, 32);
            
            faceBookIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_facebook"]];
            faceBookIcon.tag = 1;
            faceBookIcon.frame = rect;
            faceBookIcon.layer.cornerRadius = 5;
            faceBookIcon.clipsToBounds = YES;
            faceBookIcon.contentMode = UIViewContentModeScaleAspectFill;

            rect.origin.x = 72;
            rect.origin.y = 15;
            rect.size = CGSizeMake(150, 20);
            facebookLoginLabel = [[UILabel alloc] init];
            facebookLoginLabel.tag = 2;
            facebookLoginLabel.text = @"페이스북 로그인";
            facebookLoginLabel.textColor = [UIColor darkGrayColor];
            facebookLoginLabel.backgroundColor = [UIColor clearColor];
            facebookLoginLabel.frame = rect;
            
            rect.origin.x = 72;
            rect.origin.y = 35;
            rect.size = CGSizeMake(150, 30);
            messageLabel = [[UILabel alloc] init];
            messageLabel.tag = 3;
            messageLabel.text = @"허락없이 타임라인에 글을\n남기지 않아요.";
            messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            messageLabel.numberOfLines = 2;
            messageLabel.textColor = [UIColor grayColor];
            messageLabel.font = [UIFont systemFontOfSize:12];
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.frame = rect;
            
            rect.origin.x = 72;
            rect.origin.y = 27;
            rect.size = CGSizeMake(150, 20);
            facebookNameLabel = [[UILabel alloc] init];
            facebookNameLabel.tag = 4;
            facebookNameLabel.text = @"";
            facebookNameLabel.textColor = [UIColor darkGrayColor];
            facebookNameLabel.backgroundColor = [UIColor clearColor];
            facebookNameLabel.frame = rect;
            
            [cell.contentView addSubview:faceBookIcon];
            [cell.contentView addSubview:facebookLoginLabel];
            [cell.contentView addSubview:messageLabel];
            [cell.contentView addSubview:facebookNameLabel];
        }else{
            faceBookIcon = (UIImageView *)[cell.contentView viewWithTag:1];
            facebookLoginLabel = (UILabel *)[cell.contentView viewWithTag:2];
            messageLabel = (UILabel *)[cell.contentView viewWithTag:3];
            facebookNameLabel = (UILabel *)[cell.contentView viewWithTag:4];
        }
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if( [appDelegate loginCheck] ){
            facebookLoginLabel.hidden = YES;
            messageLabel.hidden = YES;
            facebookNameLabel.hidden = NO;
            facebookNameLabel.text = appDelegate.facebookName;
            [faceBookIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",appDelegate.facebookID]] placeholderImage:[UIImage imageNamed:@"ic_blank_profile"]];
        }else{
            facebookLoginLabel.hidden = NO;
            messageLabel.hidden = NO;
            facebookNameLabel.hidden = YES;
            faceBookIcon.image = [UIImage imageNamed:@"ic_facebook"];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTableCell"];
        UIImageView *kakaoIcon = nil;
        UILabel *kakaoLabel = nil;
        UILabel *messageLabel = nil;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingTableCell"];
            rect.origin.x = 25;
            rect.origin.y = 20;
            rect.size = CGSizeMake(32, 32);
            
            kakaoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_kakaotalk"]];
            kakaoIcon.tag = 1;
            kakaoIcon.frame = rect;
            kakaoIcon.layer.cornerRadius = 5;
            kakaoIcon.clipsToBounds = YES;
            kakaoIcon.contentMode = UIViewContentModeScaleAspectFill;
            
            rect.origin.x = 72;
            rect.origin.y = 15;
            rect.size = CGSizeMake(150, 20);
            kakaoLabel = [[UILabel alloc] init];
            kakaoLabel.tag = 2;
            kakaoLabel.text = @"카카오톡 공유";
            kakaoLabel.textColor = [UIColor darkGrayColor];
            kakaoLabel.backgroundColor = [UIColor clearColor];
            kakaoLabel.frame = rect;
            
            rect.origin.x = 72;
            rect.origin.y = 38;
            rect.size = CGSizeMake(150, 30);
            messageLabel = [[UILabel alloc] init];
            messageLabel.tag = 3;
            messageLabel.text = @"야간매점 앱을 친구와\n공유해보세요.";
            messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
            messageLabel.numberOfLines = 2;
            messageLabel.textColor = [UIColor grayColor];
            messageLabel.font = [UIFont systemFontOfSize:12];
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.frame = rect;

            [cell.contentView addSubview:kakaoIcon];
            [cell.contentView addSubview:kakaoLabel];
            [cell.contentView addSubview:messageLabel];
        }else{
            kakaoIcon = (UIImageView *)[cell.contentView viewWithTag:1];
            kakaoLabel = (UILabel *)[cell.contentView viewWithTag:2];
            messageLabel = (UILabel *)[cell.contentView viewWithTag:3];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


@end
