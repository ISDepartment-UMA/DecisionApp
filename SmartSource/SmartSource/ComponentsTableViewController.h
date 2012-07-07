//
//  ComponentsTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 19.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData/CoreData.h"
#import "RatingTableViewViewController.h"

@interface ComponentsTableViewController : UITableViewController <UISplitViewControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;
@property RatingTableViewViewController *ratingScreen;


- (void)setProject:(NSString *)projectID;
- (void)checkForCompleteness;
@end
