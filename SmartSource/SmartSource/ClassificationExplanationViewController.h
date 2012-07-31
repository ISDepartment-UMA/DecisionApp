//
//  ClassificationExplanationViewController.h
//  SmartSource
//
//  Created by Lorenz on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassificationExplanationViewController : UIViewController <UITableViewDataSource>

@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

- (void)setComponent:(NSString *)componentID;

@end
