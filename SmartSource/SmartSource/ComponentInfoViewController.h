//
//  ComponentInfoViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.07.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectModel.h"

@interface ComponentInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)setComponent:(Component *)component andModel:(ProjectModel *)model;

@end
