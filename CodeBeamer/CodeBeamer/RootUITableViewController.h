//
//  RootUITableViewController.h
//  SplitView
//
//  Created by Lorenz on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootUITableViewController : UITableViewController <UISplitViewControllerDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSArray *cells;  //cells that are available to display
@end
