//
//  ShowClassificationTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassificationModel.h"


@interface ShowClassificationTableViewController : UITableViewController <UISplitViewControllerDelegate>

- (void)setDisplayedClassification:(NSString *)classification fromModel:(ClassificationModel *)model;


@end
