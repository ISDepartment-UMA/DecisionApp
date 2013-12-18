//
//  SmartSourcePopoverBackgroundView.h
//  SmartSource
//
//  Created by Lorenz on 30.10.13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SmartSourcePopoverBackgroundView : UIPopoverBackgroundView

@property (readonly) UIColor *tintColor;
+ (UIColor *)currentTintColor;
+ (void)setCurrentTintColor:(UIColor *)tintColor;

@end
