//
//  ResultMaserViewController.h
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ResultMasterViewController : UITableViewController <UISplitViewControllerDelegate>
- (void)prepareResultsForProject:(NSString *)projectID;
- (void)setResultScreen:(id)resultScreen;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString *currentProjectTitle;

@end
