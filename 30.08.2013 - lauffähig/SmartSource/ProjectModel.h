//
//  ProjectModel.h
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Component+Factory.h"
#import "Project+Factory.h"

@interface ProjectModel : NSObject


- (ProjectModel *)initWithProjectID:(NSString *)projectID;
- (Project *)getProjectObject;
- (NSArray *)arrayWithComponents;
- (BOOL)ratingIsComplete;
- (NSInteger)numberOfComponents;
- (NSArray *)getProjectInfoArray;
- (NSString *)getProjectID;
- (NSString *)getProjectName;
- (NSArray *)calculateResults;
- (NSArray *)getColumnsForDecisionTable;
- (NSArray *)getComponentsForCategory:(NSString *)category;
- (BOOL)ratingCharacteristicsHaveBeenAdded;
- (BOOL)ratingCharacteristicsHaveBeenDeleted;
- (NSArray *)getCharsAndValuesArray:(NSString *)componentID;
- (Component *)getComponentObjectForID:(NSString *)componentID;
- (ProjectModel *)updateCoreDataBaseForProjectID:(NSString *)projectID;


@end
