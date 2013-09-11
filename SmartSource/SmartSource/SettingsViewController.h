//
//  SettingsViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) MainMenuViewController *mainMenu;
- (void)modalViewControllerDismissedWithView:(UIView *)view;
@end
