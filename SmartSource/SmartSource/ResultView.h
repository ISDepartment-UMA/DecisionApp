//
//  ResultView.h
//  SmartSource
//
//  Created by Lorenz on 12.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuStepSubview.h"
#import "ResultViewDelegate.h"
#import "ButtonExternalBackground.h"

@interface ResultView : MainMenuStepSubview

@property (strong, nonatomic) IBOutlet UIView *rightImageBackGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *triggerStepButton;
@property (strong, nonatomic) IBOutlet UIView *rightImageBottomView;
@end
