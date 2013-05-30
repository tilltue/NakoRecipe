//
//  RecipeViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeViewController.h"
#import "CoreDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface RecipeViewController ()

@end

@implementation RecipeViewController
@synthesize currentPostId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [CommonUI getUIColorFromHexString:@"#E4E3DC"];
    recipeView = [[RecipeView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    [self.view addSubview:recipeView];
    
    recipeCommentView = [[RecipeCommentView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-44)];
    recipeCommentView.hidden = YES;
    [self.view addSubview:recipeCommentView];
    
    CGRect tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 768, 40):CGRectMake(0, 0, 220, 40);
    CGFloat titleFontHeight;
    if( [UIFONT_NAME isEqualToString:@"HA-TTL"] )
        titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
    else
        titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
    UILabel *label = [[UILabel alloc] initWithFrame:tempRect];
    label.font = [UIFont fontWithName:UIFONT_NAME size:titleFontHeight];
    label.shadowColor = [UIColor clearColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [CommonUI getUIColorFromHexString:@"#696565"];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"";
    self.navigationItem.titleView = label;
    self.navigationItem.backBarButtonItem.tintColor = [CommonUI getUIColorFromHexString:@"#C9C5C5"];
    UIBarButtonItem *facebookComment = [[UIBarButtonItem alloc] initWithTitle:@"댓글보기" style:UIBarButtonItemStylePlain target:self action:@selector(facebookComment)];
    self.navigationItem.rightBarButtonItem = facebookComment;
}

- (void)viewWillAppear:(BOOL)animated
{
    if( currentPostId != nil ){
        [recipeView reloadRecipeView:currentPostId];
        Post *tempPost = [[CoreDataManager getInstance] getPost:currentPostId];
        NSArray *infoTextArr = [tempPost.tags componentsSeparatedByString:@"|"];
        if( [infoTextArr count] > 4 ){
            NSString *food_name       = [infoTextArr objectAtIndex:3];
            UILabel *tempLabel = (UILabel *)self.navigationItem.titleView;
            tempLabel.text = food_name;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)facebookComment
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [recipeView.window.layer addAnimation:transition forKey:nil];
    recipeView.hidden = YES;
    transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [recipeCommentView.window.layer addAnimation:transition forKey:nil];
    recipeCommentView.hidden = NO;
}

@end
