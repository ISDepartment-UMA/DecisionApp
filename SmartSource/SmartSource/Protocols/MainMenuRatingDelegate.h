//
//  MainMenuRatingDelegate.h
//  SmartSource
//
//  Created by Lorenz on 06.12.13.
//
//

#import <Foundation/Foundation.h>
#import "ProjectModel.h"

@protocol MainMenuRatingDelegate <NSObject>

- (void)setProjectModel:(ProjectModel *)projectModel;
- (ProjectModel *)getProjectModel;

@end
