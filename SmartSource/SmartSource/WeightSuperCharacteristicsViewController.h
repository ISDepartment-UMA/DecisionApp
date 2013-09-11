//
//  WeightSuperCharacteristicsViewController.h
//  SmartSource
//
//  Created by Lorenz on 08.09.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectModel.h"
#import "RatingTableViewViewController.h"

@interface WeightSuperCharacteristicsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (void)setRatingDelegate:(RatingTableViewViewController *)delegate;
- (void)saveContext;
@end
