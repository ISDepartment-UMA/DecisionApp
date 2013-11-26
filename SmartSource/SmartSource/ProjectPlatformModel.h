//
//  ProjectPlatformModel.h
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import <Foundation/Foundation.h>
#import "ProjectPlatformModelDelegate.h"

@interface ProjectPlatformModel : NSObject

@property (nonatomic) BOOL projectsFromWebServiceAvailable;

- (ProjectPlatformModel *)init;
- (NSArray *)getStoredProjects;
- (void)deleteProjectWithID:(NSString *)projectID;
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID;
- (NSArray *)getSelectedProject;
- (void)setSelectedProject:(NSArray *)projectID;
- (BOOL)ratingCharacteristicsHaveChangedForProject:(NSString *)projectID;
- (NSArray *)getAllProjectsNamesAndSetDelegate:(id<ProjectPlatformModelDelegate>)delegate;


@end
