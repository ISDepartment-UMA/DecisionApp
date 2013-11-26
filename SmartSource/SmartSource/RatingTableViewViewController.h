//
//  RatingTableViewViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component+Factory.h"
#import "Slider.h"
#import "ProjectModel.h"
#import "ModalAlertViewControllerDelegate.h"
#import "CharacteristicCellDelegate.h"


@interface RatingTableViewViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, ModalAlertViewControllerDelegate, CharacteristicCellDelegate>

- (void)setProjectModel:(ProjectModel *)projectModel;
- (ProjectModel *)getProjectModel;
- (NSString *)getCurrentProjectName;
- (void)setComponent:(Component *)component;
- (Component *)getSelectedComponent;
- (NSArray *)getAvailableComponents;
- (void)returnToMainMenu;
- (void)masterViewIsThere;
- (void)masterViewIsNotThere;

@property (nonatomic) Component *displayedComponent;
@property (nonatomic) BOOL componentRatingIsComplete;
@property (nonatomic) BOOL weightingIsComplete;


@end
