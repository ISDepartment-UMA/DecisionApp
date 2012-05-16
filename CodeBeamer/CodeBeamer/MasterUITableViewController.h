//
//  MasterUITableViewController.h
//  SplitView
//
//  Created by Lorenz on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterUITableViewController : UITableViewController <UISplitViewControllerDelegate>
@property (strong, nonatomic) NSArray *cells;
@end
