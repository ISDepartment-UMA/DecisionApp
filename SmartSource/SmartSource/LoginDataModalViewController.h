//
//  LoginDataModalViewController.h
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsModel.h"
@interface LoginDataModalViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>


- (void)setSettingsModel:(SettingsModel *)settingsModel;

@end
