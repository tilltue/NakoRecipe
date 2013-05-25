//
//  RecipeViewController.m
//  NakoRecipe
//
//  Created by tilltue on 13. 5. 19..
//  Copyright (c) 2013년 tilltue. All rights reserved.
//

#import "RecipeViewController.h"
#import "CoreDataManager.h"

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

#pragma mark - gesture handler

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}

- (void)initGestureRecognizer:(UIView *)view
{
    UITapGestureRecognizer *tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.cancelsTouchesInView = NO;
    tapRecognizer.delegate = self;
    [view addGestureRecognizer:tapRecognizer];
}

-(void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if( [SystemInfo isPad] ){
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }else{
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
