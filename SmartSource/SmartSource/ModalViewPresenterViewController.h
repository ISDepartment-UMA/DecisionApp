//
//  ModalViewPresenterViewController.h
//  SmartSource
//
//  Created by Lorenz on 28.08.13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface ModalViewPresenterViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>


@property (nonatomic, strong) UIView *viewToPresent;
@property (nonatomic, strong) SettingsViewController *delegate;
@property (nonatomic) BOOL appendAbortAndEnterButton;

@end
