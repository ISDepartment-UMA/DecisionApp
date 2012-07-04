//
//  Component+Factory.m
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Component+Factory.h"
#import "Project+Factory.h"

@implementation Component (Factory)


+ (Component *)addNewComponent:(NSString *)componentID toProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Component *comp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    request.predicate = [NSPredicate predicateWithFormat:@"id =%@", componentID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        comp = [NSEntityDescription insertNewObjectForEntityForName:@"Component" inManagedObjectContext:context];
        comp.id = componentID;
        comp.name = @"";
        comp.descr = @"";
        comp.partOf = [Project addNewProject:projectID toManagedObjectContext:context];
        
    } else {
        comp = [matches lastObject];
    }
    
    return comp;
    
    
}
@end
