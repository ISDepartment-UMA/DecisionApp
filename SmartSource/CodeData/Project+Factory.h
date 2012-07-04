//
//  Project+Factory.h
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Project.h"

@interface Project (Factory)
+ (Project *)addNewProject:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context;
@end
