//
//  EvaluationView.h
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import <UIKit/UIKit.h>
#import "EvaluationViewDelegate.h"
#import "ButtonExternalBackground.h"

@interface EvaluationView : UIView

//subview for evaluation
@property (strong, nonatomic) IBOutlet UIView *rightImageBackGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *evaluationButton;
@property (strong, nonatomic) IBOutlet UIView *rightImageBottomView;

//delegate
@property (nonatomic, strong) id <EvaluationViewDelegate> delegate;

- (void)setActiveForEvaluation;
- (void)setDeactiveForEvaliation;
- (void)deactivateUserInteraction;
- (void)reactivateUserInteraction;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)setEmpty;

@end
