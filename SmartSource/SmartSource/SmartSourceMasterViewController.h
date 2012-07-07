//
//  SmartSourceMasterViewController.h
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailTableViewController.h"

@class SmartSourceDetailViewController;

#import <CoreData/CoreData.h>

@interface SmartSourceMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) SmartSourceDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) DetailTableViewController *detailScreen;



@end
