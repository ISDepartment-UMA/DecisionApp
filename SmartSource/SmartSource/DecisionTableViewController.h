//
//  ResultTableViewController.h
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectModel.h"

@interface DecisionTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (void)setProjectModel:(ProjectModel *)projectModel;
- (void)markComponentAsSelected:(Component *)component;



@end
