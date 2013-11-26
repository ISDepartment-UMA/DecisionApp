//
//  ProjectSelectionViewController.h
//  SmartSource
//
//  Created by Lorenz on 01.07.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectPlatformModel.h"
#import "ProjectPlatformModelDelegate.h"
#import "ProjectSelectionViewControllerDelegate.h"
#import "ModalAlertViewControllerDelegate.h"


@interface ProjectSelectionViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, ProjectPlatformModelDelegate, UIPopoverControllerDelegate>

- (void)setDelegate:(id<ProjectSelectionViewControllerDelegate>)delegate;
- (void)setPlatformModel:(ProjectPlatformModel *)platformModel;
@end
