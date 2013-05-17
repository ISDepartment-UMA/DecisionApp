//
//  ChartViewController.h
//  SmartSource
//
//  Created by Lorenz on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartViewController : UIViewController <UISplitViewControllerDelegate>



- (void)initializeClassificationForProject:(NSString *)projectID;
- (NSArray *)getClassificationForCurrentProject;
- (void)showDecisionTable;
- (void)showClassification:(NSString *)classification;



@end
