//
//  ProjectSelectionViewControllerDelegate.h
//  SmartSource
//
//  Created by Lorenz on 14.11.13.
//
//

#import <Foundation/Foundation.h>
#import "ProjectPlatformModel.h"
@protocol ProjectSelectionViewControllerDelegate <NSObject>

- (void)projectSelectionViewControllerHasBeenDismissedWithPlatformModel:(ProjectPlatformModel *)platformModel;
@end
