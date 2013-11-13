//
//  ModalAlertViewControllerDelegate.h
//  SmartSource
//
//  Created by Lorenz on 11.11.13.
//
//

#import <Foundation/Foundation.h>

@protocol ModalAlertViewControllerDelegate <NSObject>

- (void)modalViewControllerHasBeenDismissedWithInput:(NSString *)input;

@end
