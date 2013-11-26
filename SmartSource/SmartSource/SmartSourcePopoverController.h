//
//  SmartSourcePopoverController.h
//  SmartSource
//
//  Created by Lorenz on 30.10.13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SmartSourcePopoverController : UIPopoverController

- (id)initWithContentViewController:(UIViewController *)viewController andTintColor:(UIColor *)tintColor;

@end