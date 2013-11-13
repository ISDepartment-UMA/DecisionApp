//
//  ModalAlertViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.10.13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "ModalAlertViewControllerDelegate.h"

@interface ModalAlertViewController : UIViewController

- (void)setStringForacknowledgeButton:(NSString *)stringForacknowledgeButton;
- (void)setStringForcancelButton:(NSString *)stringForcancelButton;
- (void)setStringForTextLabel:(NSString *)stringForTextLabel;
- (void)setStringForTitleLabel:(NSString *)stringForTitleLabel;
- (void)setDelegate:(id<ModalAlertViewControllerDelegate>)delegate;
@end
