//
//  ProjectSelectionViewController.h
//  SmartSource
//
//  Created by Lorenz on 01.07.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectPlatformModel.h"


@interface ProjectSelectionViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ProjectPlatformModel *platformModel;
@end
