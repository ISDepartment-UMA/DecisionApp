//
//  EvaluationView.h
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import <UIKit/UIKit.h>
#import "MainMenuStepSubview.h"
#import "EvaluationViewDelegate.h"
#import "ButtonExternalBackground.h"

@interface EvaluationView : MainMenuStepSubview
//redefine outlets
@property (strong, nonatomic) IBOutlet UIView *rightImageBackGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *triggerStepButton;
@property (strong, nonatomic) IBOutlet UIView *rightImageBottomView;
@end
