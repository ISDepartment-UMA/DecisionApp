//
//  RatingTableViewViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingTableViewViewController : UITableViewController <UISplitViewControllerDelegate>
@property NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *managedObjectContext;

- (void)setComponent:(NSString *)componentID ofProject:(NSString *)projectID withRatingCharacteristics:(NSArray *)characteristics;
- (void)saveValueForSlider:(UISlider *)slider;
@end
