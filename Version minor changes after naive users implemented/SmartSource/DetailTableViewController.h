//
//  DetailTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"
#import "StatusReciever.h"

@interface DetailTableViewController : UITableViewController <UISplitViewControllerDelegate>


- (NSArray *)getAvailableProjects;
- (void)selectProjectWithID:(NSString *)projectID;
- (void)getProjectsFromWebService;
- (NSInteger)getProjectsFromCoreDataAndReturnNumber;


@end
