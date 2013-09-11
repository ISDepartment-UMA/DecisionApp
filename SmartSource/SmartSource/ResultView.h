//
//  ResultView.h
//  SmartSource
//
//  Created by Lorenz on 12.08.13.
//
//

#import <UIKit/UIKit.h>
#import "ResultViewDelegate.h"
#import "ButtonExternalBackground.h"

@interface ResultView : UIView

@property (strong, nonatomic) IBOutlet UIView *rightImageBackGroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *showResultsButton;
@property (strong, nonatomic) IBOutlet UIView *rightImageBottomView;

//delegate
@property (nonatomic, strong) id <ResultViewDelegate> delegate;


- (void)setDeactiveToShowResults;
- (void)setActiveToShowResults;
- (void)deactivateUserInteraction;
- (void)reactivateUserInteraction;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)setEmpty;


@end
