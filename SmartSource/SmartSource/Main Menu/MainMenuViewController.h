//
//  MainMenuViewController.h
//  SmartSource
//
//  Created by Lorenz on 01.07.13.
//
//

#import <UIKit/UIKit.h>
#import "ModalViewControllerPresenter.h"
#import "RatingTableViewViewController.h"
#import "EvaluationViewDelegate.h"
#import "ResultViewDelegate.h"
#import "ProjectSelectionViewControllerDelegate.h"

@interface MainMenuViewController : UIViewController <UIScrollViewDelegate, EvaluationViewDelegate, ResultViewDelegate, ProjectSelectionViewControllerDelegate>
@property (nonatomic, weak) RatingTableViewViewController *ratingScreen;

- (void)modalViewControllerHasBeenDismissed;
- (void)resetProjectModel;


@end