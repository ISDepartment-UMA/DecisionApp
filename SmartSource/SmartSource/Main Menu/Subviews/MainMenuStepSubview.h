//
//  MainMenuStepSubview.h
//  SmartSource
//
//  Created by Lorenz on 16.12.13.
//
//

#import <UIKit/UIKit.h>
#import "EvaluationViewDelegate.h"
#import "ButtonExternalBackground.h"
#import "EvaluationViewDelegate.h"
#import "ResultViewDelegate.h"

@interface MainMenuStepSubview : UIView
//outlets to UIElements
@property (strong, nonatomic) IBOutlet UIView *rightImageBackGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *triggerStepButton;
@property (strong, nonatomic) IBOutlet UIView *rightImageBottomView;
//delegate
@property (nonatomic, strong) id delegate;
//methods
- (void)setActive;
- (void)setDeactive;
- (void)deactivateUserInteraction;
- (void)reactivateUserInteraction;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)setEmpty;


@end
