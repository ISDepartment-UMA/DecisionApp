//
//  SettingsViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"
#import "ModalAlertViewControllerDelegate.h"
#import "SettingsDelegate.h"
#import "SettingsDelegate.h"


@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, ModalAlertViewControllerDelegate>

- (void)setDelegate:(id<SettingsDelegate>)delegate;
- (void)modalViewControllerHasBeenDismissedWithInput:(NSString *)input;
@end
