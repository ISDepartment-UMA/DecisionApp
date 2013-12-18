//
//  RatingTableViewViewController.h
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component+Factory.h"
#import "ProjectModel.h"
#import "ModalAlertViewControllerDelegate.h"
#import "CharacteristicCellDelegate.h"
#import "MainMenuRatingDelegate.h"
#import "WeightSuperCharacteristicsRatingDelegate.h"
#import "ComponentSelectionRatingDelegate.h"


@interface RatingTableViewViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, ModalAlertViewControllerDelegate, CharacteristicCellDelegate, MainMenuRatingDelegate, WeightSuperCharacteristicsRatingDelegate, ComponentSelectionRatingDelegate>

- (NSString *)getCurrentProjectName;
@property (nonatomic) Component *displayedComponent;


@end
