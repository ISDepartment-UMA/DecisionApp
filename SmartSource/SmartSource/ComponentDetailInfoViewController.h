//
//  ComponentDetailInfoViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComponentDetailInfoViewController : UITableViewController <UISplitViewControllerDelegate>
@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

- (void)setComponent:(NSString *)componentID;

@end
