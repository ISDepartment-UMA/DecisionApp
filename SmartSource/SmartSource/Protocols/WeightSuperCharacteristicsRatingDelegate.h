//
//  WeightSuperCharacteristicsRatingDelegate.h
//  SmartSource
//
//  Created by Lorenz on 06.12.13.
//
//

#import <Foundation/Foundation.h>
#import "ProjectModel.h"

@protocol WeightSuperCharacteristicsRatingDelegate <NSObject>

@property (nonatomic) BOOL componentRatingIsComplete;
@property (nonatomic) BOOL weightingIsComplete;
- (void)returnToMainMenu;
- (ProjectModel *)getProjectModel;

@end
