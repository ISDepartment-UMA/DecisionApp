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


@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, ModalAlertViewControllerDelegate>

@property (nonatomic, strong) MainMenuViewController *mainMenu;
- (void)modalViewControllerHasBeenDismissedWithInput:(NSString *)input;
@end
