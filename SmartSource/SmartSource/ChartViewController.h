//
//  ChartViewController.h
//  SmartSource
//
//  Created by Lorenz on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultMasterViewController.h"

@interface ChartViewController : UIViewController <UISplitViewControllerDelegate>


@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;
- (void)setResultMasterScreen:(id)resultMasterScreen;


- (void)createViewForProject:(NSArray *)componentClassification;
@end
