//
//  DetailTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"

@interface DetailTableViewController : UITableViewController <UISplitViewControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;
- (void)setProjectDetails:(NSString *)projectID;


@end
