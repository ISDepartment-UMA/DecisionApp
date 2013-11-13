//
//  Project+Factory.m
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Project+Factory.h"
#import "SBJson.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "WebServiceConnector.h"

@implementation Project (Factory)

+ (Project *)addNewProject:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context withTimestamp:(NSDate *)timestamp
{
    Project *pro = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        pro = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:context];
        pro.projectID = projectID;
        
        //get further project information
        NSDictionary *projectInformation = [WebServiceConnector getProjectInfoDictionary:projectID];
        pro.name = [projectInformation objectForKey:@"name"];
        pro.descr = [projectInformation objectForKey:@"description"];
        pro.category = [projectInformation objectForKey:@"category"];
        pro.startdate = [projectInformation objectForKey:@"start"];
        pro.enddate = [projectInformation objectForKey:@"end"];
        pro.creator = [projectInformation objectForKey:@"creator"];
        pro.weightingHasBeenEdited = [NSNumber numberWithBool:NO];
        pro.timestamp = timestamp;
        
        //save context
        [Project saveContext:context];
        
    } else {
        pro = [matches lastObject];
    }
    
    return pro;
    
    
}

+ (Project *)getProjectForId:(NSString *)projectID fromManagedObjectContext:(NSManagedObjectContext *)context
{
    //search for right project and return it
    NSFetchRequest *requestA = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    requestA.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    
    NSSortDescriptor *sortDescriptionA = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    requestA.sortDescriptors = [NSArray arrayWithObject:sortDescriptionA];
    NSError *errorA = nil;
    NSArray *matchesA = [context executeFetchRequest:requestA error:&errorA];
    if ([matchesA count] > 0) {
        return [matchesA lastObject];
    } else {
        return nil;
    }
    
}

+ (NSArray *)getStoredAllStoredProjectsFromManagedObjectContext:(NSManagedObjectContext *)context
{
    //get all projects from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
    
}

//reacts to the user's selection in the alert view to delete the project rating
+ (BOOL)deleteProjectWithID:(NSString *)projectID fromManagedObjectContext:(NSManagedObjectContext *)context
{
    
    //then delete the current rating from the core database
    //look for project in core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //delete project
    //deletion rule in core database is set to cascade, so deleting the project will delete all components, supercharacteristics and characteristics
    [context deleteObject:[matches objectAtIndex:0]];
    
    //save context
    return [Project saveContext:context];
}

+ (BOOL)saveContext:(NSManagedObjectContext *)context
{
    
    //save context
    NSError *error = nil;
    if (![context save:&error]) {
        return NO;
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        return YES;
    }
    
}

@end
