//
//  DetailTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"
#import "CodeBeamerModel.h"

@interface DetailTableViewController : UITableViewController <UISplitViewControllerDelegate>


- (NSArray *)getAvailableProjects;
- (void)selectProjectWithID:(NSString *)projectID;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end
