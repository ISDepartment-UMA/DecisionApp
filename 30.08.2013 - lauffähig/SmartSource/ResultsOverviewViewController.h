//
//  ResultsOverviewViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.07.13.
//
//

#import <UIKit/UIKit.h>
#import "ProjectModel.h"

@interface ResultsOverviewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) ProjectModel *projectModel;

@end
