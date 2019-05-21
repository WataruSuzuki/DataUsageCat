//
//  DJKViewUtils.h
//  DJKUtilities
//
//  Created by Wataru Suzuki on 2013/11/17.
//  Copyright (c) 2013年 Wataru Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DJKViewUtils : UIView

extern const float HEIGHT_960_640;
extern const float HEIGHT_1136_640;

extern const float OFFSET_NEEDLE_SLOPE;
extern const float ADJUST_ANGLE;
extern const float OFFSET_START_ANGLE;

extern const float TIME_DELAY_1SECOND;

extern const float DISP_AD_OFFSET_ON;
extern const float DISP_AD_OFFSET_OFF;

+(void)setConstraintCenterX:(UIView *)targetView
                CurrentView:(UIView *)currentView;
+(void)setConstraintBottomView:(UIView *)targetView
                  CurrentAndTo:(UIView *)currentAndToView;
+(void)setConstraintBottomView:(UIView *)targetView
                        ToItem:(UIView *)toItem
                   CurrentView:(UIView *)currentView;
+(void)relayoutBottomViewBeforeRemoveAd:(UIView *)updateView
                               AdBanner:(UIView *)removeAdView
                            CurrentView:(UIView *)currentView
                             AutoLayout:(BOOL)isAutoLayout;
+(CGRect)changeHeightToDisplaySize:(CGRect)frame beforeSize:(int)beforeSize afterSize:(int)afterSize;
+(void)initScrollViewForPaging:(UIScrollView *)scrollView
               withPageNumbers:(NSUInteger)numberPages
             andTargetDelegate:(id)delegate;
+(NSUInteger)getPageOfScrollView:(UIScrollView *)scrollView;
+(void)offsetScrollViewBeforeInit:(UIView *)targetView
                      offsetWidth:(CGFloat)width;

+(void)blinkButton:(UIButton *)button
      withDuration:(float)duration
   withRepeatCount:(int)repeatCount;

+(UIView *)getKeyboardsAccessoriesWithTargetTextView:(UITextView *)targetTextView
                                   withLeftImageName:(NSString *)leftImageName
                                  withRightImageName:(NSString *)rightImageName
                                      withLeftTarget:(SEL)leftTarget
                                     withRightTarget:(SEL)rightTarget
                                     accessoryHeight:(float)accessoryHeight
                                            senderVC:(UIViewController *)senderVC;

@end
