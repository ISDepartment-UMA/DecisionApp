//
//  ClassificationExplanationViewController.h
//  SmartSource
//
//  Created by Lorenz on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassificationModel.h"

@interface ClassificationExplanationViewController : UIViewController <UITableViewDataSource>

- (void)setComponent:(NSString *)componentID andModel:(ClassificationModel *)model;

@end
