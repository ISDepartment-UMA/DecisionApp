//
//  SettingsTableViewControllerViewController.h
//  SmartSource
//
//  Created by Lorenz on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewControllerViewController : UITableViewController

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

@end
