//
//  ComponentDetailInfoViewController.h
//  SmartSource
//
//  Created by Lorenz on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClassificationModel.h"

@interface ComponentDetailInfoViewController : UITableViewController


- (void)setComponent:(NSString *)componentID andModel:(ClassificationModel *)model;
@property (strong, nonatomic) Component *displayedComponent;



@end
