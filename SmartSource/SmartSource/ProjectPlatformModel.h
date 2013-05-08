//
//  ProjectPlatformModel.h
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import <Foundation/Foundation.h>

@interface ProjectPlatformModel : NSObject
- (NSArray *)getAllProjectNames;
- (ProjectPlatformModel *)init;
- (NSArray *)getStoredProjects;
- (NSArray *)getProjectInfo:(NSString *)projectID;
- (void)deleteProjectWithID:(NSString *)projectID;
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID;
- (NSArray *)getSelectedProject;
- (void)setSelectedProject:(NSArray *)projectID;
- (BOOL)ratingCharacteristicsHaveChangedForProject:(NSString *)projectID;


@end
