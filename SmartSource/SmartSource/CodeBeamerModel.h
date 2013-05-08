//
//  CodeBeamerModel.h
//  SmartSource
//
//  Created by Lorenz on 19.02.13.
//
//

#import <Foundation/Foundation.h>
#import "DetailTableViewController.h"


@interface CodeBeamerModel : NSObject

- (NSArray *)getAllProjectNames;
- (CodeBeamerModel *)init;
- (NSArray *)getStoredProjects;
- (NSArray *)getProjectInfo:(NSString *)projectID;
- (void)deleteProjectWithID:(NSString *)projectID;
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID;
- (NSArray *)getSelectedProject;
- (void)setSelectedProject:(NSArray *)projectID;


@end
