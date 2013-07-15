//
//  RecipeViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeViewController.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"
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
        CGRect tempRect = self.view.bounds;
        tempRect.origin = CGPointZero;
        tempRect.size.height -=44;
        recipeView = [[RecipeView alloc] initWithFrame:tempRect];
        [self.view addSubview:recipeView];
        
        tempRect.origin.x = 0;
        tempRect.origin.y = tempRect.size.height-40;
        tempRect.size.height = 40;
        recipeCommentView = [[RecipeCommentView alloc] initWithFrame:tempRect];
        recipeCommentView.comment_delegate = self;
        recipeCommentView.backgroundColor = [CommonUI getUIColorFromHexString:@"#F4F3F4"];
        recipeCommentView.layer.shadowOffset = CGSizeMake(-0.5, 0.5);
        recipeCommentView.layer.shadowRadius = 2;
        recipeCommentView.layer.shadowOpacity = 0.2;
        [self.view addSubview:recipeCommentView];
        
        tempRect = [SystemInfo isPad]?CGRectMake(0, 0, 768, 40):CGRectMake(0, 0, 220, 40);
        CGFloat titleFontHeight;
        if( [UIFONT_NAME isEqualToString:@"HA-TTL"] )
            titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
        else
            titleFontHeight = [SystemInfo isPad]?24.0:24.0f;
        UILabel *label = [[UILabel alloc] initWithFrame:tempRect];
        label.font = [UIFont fontWithName:UIFONT_NAME size:titleFontHeight];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"";
        self.navigationItem.titleView = label;
    }
    return self;
}

- (void)shapeView:(UIView *)view
{
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5.0, 5.0)].CGPath;
    view.layer.masksToBounds = YES;
    view.layer.mask = shapeLayer;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [CommonUI getUIColorFromHexString:@"#E4E3DC"];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [recipeView reset];
}

- (void)prepareWillAppear
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

@end
