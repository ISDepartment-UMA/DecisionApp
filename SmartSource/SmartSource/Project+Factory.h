//
//  Project+Factory.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Project.h"

@interface Project (Factory)
+ (Project *)addNewProject:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context withTimestamp:(NSDate *)timestamp;
+ (Project *)getProjectForId:(NSString *)projectID fromManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)getStoredAllStoredProjectsFromManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteProjectWithID:(NSString *)projectID fromManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)saveContext:(NSManagedObjectContext *)context;
@end
