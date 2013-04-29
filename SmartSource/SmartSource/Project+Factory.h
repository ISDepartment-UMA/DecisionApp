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
+ (Project *)initProjectFromID:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context;
@end
