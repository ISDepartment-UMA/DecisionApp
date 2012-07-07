//
//  ResultTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DecisionTableViewController : UITableViewController <UISplitViewControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;
- (void)createRatingTable:(NSString *)projectID;

@end
