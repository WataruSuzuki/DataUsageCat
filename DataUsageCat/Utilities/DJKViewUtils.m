//
//  DJKViewUtils.m
//  DJKUtilities
//
//  Created by Wataru Suzuki on 2013/11/17.
//  Copyright (c) 2013年 Wataru Suzuki. All rights reserved.
//

#import "DJKViewUtils.h"

@implementation DJKViewUtils

const float HEIGHT_960_640 = 480;
const float HEIGHT_1136_640 = 568;

const float OFFSET_NEEDLE_SLOPE = 2;
const float ADJUST_ANGLE = (45 - OFFSET_NEEDLE_SLOPE);
const float OFFSET_START_ANGLE = (-45 - OFFSET_NEEDLE_SLOPE);

const float TIME_DELAY_1SECOND = 1.0;

const float DISP_AD_OFFSET_ON = (-50.0);
const float DISP_AD_OFFSET_OFF = (50.0);

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(void)setConstraintCenterX:(UIView *)targetView
                CurrentView:(UIView *)currentView
{
    NSLayoutConstraint *layoutCenterX =
    [NSLayoutConstraint constraintWithItem:targetView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:currentView
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0];
    [currentView addConstraint:layoutCenterX];
}

+(CGRect)changeHeightToDisplaySize:(CGRect)frame beforeSize:(int)beforeSize afterSize:(int)afterSize{
    CGRect retFrame;
    
    retFrame = frame;
    retFrame.size.height = retFrame.size.height * (afterSize / beforeSize);
    
    return retFrame;
}

+(void)initScrollViewForPaging:(UIScrollView *)scrollView
               withPageNumbers:(NSUInteger)numberPages
             andTargetDelegate:(id)delegate
{
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numberPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    
    UIViewController *controller = (UIViewController *)delegate;
    controller.automaticallyAdjustsScrollViewInsets = NO;
    
    scrollView.contentOffset = CGPointMake(CGRectGetWidth(scrollView.frame) * (numberPages -1), 0);
    scrollView.delegate = delegate;
}

+(NSUInteger)getPageOfScrollView:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSUInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    return page;
}

+(void)offsetScrollViewBeforeInit:(UIView *)targetView
                      offsetWidth:(CGFloat)width
{
    CGRect frame = targetView.frame;
    frame.size.width = width;
    targetView.frame = frame;
}

+(void)blinkButton:(UIButton *)button
      withDuration:(float)duration
   withRepeatCount:(int)repeatCount
{
    CAKeyframeAnimation *blinkAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    blinkAnimation.duration = duration;
    blinkAnimation.repeatCount = repeatCount;
    blinkAnimation.values = @[@1.0f,
                             @0.0f,
                             @1.0f];
    [button.layer addAnimation:blinkAnimation forKey:@"blink"];
}

+(UIView *)getKeyboardsAccessoriesWithTargetTextView:(UITextView *)targetTextView
                                   withLeftImageName:(NSString *)leftImageName
                                  withRightImageName:(NSString *)rightImageName
                                      withLeftTarget:(SEL)leftTarget
                                     withRightTarget:(SEL)rightTarget
                                     accessoryHeight:(float)accessoryHeight
                                            senderVC:(UIViewController *)senderVC
{
    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* leftImage = [UIImage imageNamed:leftImageName];
    [leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
    
    CGFloat padding = 2.0;
    leftButton.frame = CGRectMake(padding, padding, (leftImage.size.width + padding), (leftImage.size.height + padding));
    [leftButton addTarget:senderVC action:leftTarget forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* rightImage = [UIImage imageNamed:rightImageName];
    [rightButton setBackgroundImage:rightImage forState:UIControlStateNormal];
    
    rightButton.frame = CGRectMake((senderVC.view.frame.size.width - rightImage.size.width - padding),
                                    padding, (rightImage.size.width + padding), (rightImage.size.height + padding));
    [rightButton addTarget:senderVC action:rightTarget forControlEvents:UIControlEventTouchUpInside];
    
    UIView* accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, targetTextView.frame.size.width, accessoryHeight)];
    accessoryView.backgroundColor = [UIColor whiteColor];
    [accessoryView addSubview:leftButton];
    [accessoryView addSubview:rightButton];
    
    return accessoryView;
}

@end
