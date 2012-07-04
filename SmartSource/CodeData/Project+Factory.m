//
//  Project+Factory.m
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Project+Factory.h"

@implementation Project (Factory)


+ (Project *)addNewProject:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context
{
    Project *pro = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"id =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        pro = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
        pro.id = projectID;
        pro.name = @"";
        pro.descr = @"";
        
    } else {
        pro = [matches lastObject];
    }
    
    return pro;
    
    
}
@end
