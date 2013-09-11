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


@interface RatingTableViewViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDataSource>

- (void)setProjectModel:(ProjectModel *)projectModel;
- (ProjectModel *)getProjectModel;
- (NSString *)getCurrentProjectName;
- (void)setComponent:(Component *)component;
- (Component *)getSelectedComponent;
- (NSArray *)getAvailableComponents;
- (void)saveValueForSlider:(Slider *)slider;
- (void)checkForCompleteness;
- (void)saveContext;

@property (nonatomic) Component *displayedComponent;


@end
