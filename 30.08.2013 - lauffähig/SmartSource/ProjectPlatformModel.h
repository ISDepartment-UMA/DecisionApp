//
//  ProjectPlatformModel.h
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import <Foundation/Foundation.h>

@interface ProjectPlatformModel : NSObject

@property (nonatomic) BOOL projectsFromWebServiceAvailable;

- (NSArray *)getAllProjectNames;
- (ProjectPlatformModel *)init;
- (NSArray *)getStoredProjects;
- (void)deleteProjectWithID:(NSString *)projectID;
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID;
- (NSArray *)getSelectedProject;
- (void)setSelectedProject:(NSArray *)projectID;
- (BOOL)ratingCharacteristicsHaveChangedForProject:(NSString *)projectID;


@end
