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

//delegate to talk back to once a project has been selected
- (void)setDelegate:(id<ProjectSelectionViewControllerDelegate>)delegate;
//platform model to retrieve projects from, needs to be set during segue
- (void)setPlatformModel:(ProjectPlatformModel *)platformModel;


@end
