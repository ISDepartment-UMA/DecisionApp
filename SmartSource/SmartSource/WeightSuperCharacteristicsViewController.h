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
#import "WeightSliderDelegate.h"

@interface WeightSuperCharacteristicsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WeightSliderDelegate>
//delegate needs to be set during push segue
- (void)setRatingDelegate:(id<WeightSuperCharacteristicsRatingDelegate>)delegate;
@end
