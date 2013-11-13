//
//  AddEditCharacteristicModalViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.10.13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface AddEditCharacteristicModalViewController : UIViewController <UITextFieldDelegate>
- (void)setStringForTitleLabel:(NSString *)stringForTitleLabel;
- (void)setStringForTextField:(NSString *)stringForTextField;
- (void)setSettingsDelegate:(SettingsViewController *)delegate;

@end
