//
//  WebServiceModalViewController.h
//  SmartSource
//
//  Created by Lorenz on 08.10.13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsModel.h"

@interface WebServiceModalViewController : UIViewController <UITextViewDelegate>

- (void)setSettingsModel:(SettingsModel *)settingsModel;

@end
