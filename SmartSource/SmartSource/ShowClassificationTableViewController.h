//
//  ShowClassificationTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowClassificationTableViewController : UITableViewController <UISplitViewControllerDelegate>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

- (void)setDisplayedClassification:(NSString *)classification withComponents:(NSArray *)components;;

@end
