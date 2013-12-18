//
//  ResultExplanationViewController.h
//  SmartSource
//
//  Created by Lorenz on 18.08.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectModel.h"

@interface ResultExplanationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)setComponent:(Component *)component andModel:(ProjectModel *)model;

@end
