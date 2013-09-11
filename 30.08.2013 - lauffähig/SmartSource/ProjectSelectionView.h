//
//  ProjectSelectionView.h
//  SmartSource
//
//  Created by Lorenz on 09.08.13.
//
//

#import <UIKit/UIKit.h>
#import "Project+Factory.h"
#import "ButtonExternalBackground.h"

@interface ProjectSelectionView : UIView


@property (strong, nonatomic) IBOutlet UIView *rightImageBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UILabel *labelProjectName;
@property (strong, nonatomic) IBOutlet UILabel *labelProjectDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelCategory;
@property (strong, nonatomic) IBOutlet UILabel *labelCreator;
@property (strong, nonatomic) IBOutlet UILabel *labelEndDate;
@property (strong, nonatomic) IBOutlet UILabel *labelStartDate;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *selectProjectButton;
@property (strong, nonatomic) IBOutlet UIView *projectInfoView;


- (void)setDisplayedProject:(Project *)project;
- (void)fitForPortraitMode;
- (void)fitForLandscapeMode;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;
- (void)deactivateUserInteraction;
- (void)reactivateUserInteraction;
- (void)addActionsToSubviews;
- (void)setEmpty;

@end
