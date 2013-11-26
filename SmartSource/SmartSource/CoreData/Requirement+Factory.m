//
//  Requirement+Factory.m
//  SmartSource
//
//  Created by Lorenz on 14.11.13.
//
//

#import "Requirement+Factory.h"
#import "Project+Factory.h"
#import "Component+Factory.h"

@implementation Requirement (Factory)


/*
 * add requirement only with id, without name or linked requirements
 * maximalistic way --> this method gets called once for each requirement
 *                  --> and adds id, name as well as linked requirements
 *
 */
+ (Requirement *)addNewRequirementWithId:(NSString *)reqId andName:(NSString *)name andLinkedRequirements:(NSArray *)linkedRequirements andLinkedComponents:(NSArray *)linkedComponents andProjectId:(NSString *)projectId toManagedObjectContext:(NSManagedObjectContext *)context
{
    Requirement *req= nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Requirement"];
    request.predicate = [NSPredicate predicateWithFormat:@"requirementID =%@", reqId];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        //add new entity of SuperCharacteristic and set the name
        req = [NSEntityDescription insertNewObjectForEntityForName:@"Requirement" inManagedObjectContext:context];
        req.requirementID = reqId;
    } else {
        //requirement already exists
        req = [matches lastObject];
    }
    
    //set name and project
    req.name = name;
    req.linkedProject = [Project getProjectForId:projectId fromManagedObjectContext:context];
    
    //set linked requirements
    for (NSString *idOfLinkedReq in linkedRequirements) {
        Requirement *reqToAdd = [Requirement addNewRequirementWithId:idOfLinkedReq toManagedObjectContext:context];
        [req addLinkedWithObject:reqToAdd];
    }
    
    for (NSString *componentId in linkedComponents) {
        [req addLinkedComponentsObject:[Component addNewComponent:componentId toProject:projectId andManagedObjectContext:context]];
    }

    
    //save context
    [Requirement saveContext:context];
    
    return req;
}

/*
 * add requirement only with id, without name or linked requirements
 * minimalistic way --> names and linked requirements will be added later
 *
 */
+ (Requirement *)addNewRequirementWithId:(NSString *)reqId toManagedObjectContext:(NSManagedObjectContext *)context
{
    Requirement *req= nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Requirement"];
    request.predicate = [NSPredicate predicateWithFormat:@"requirementID =%@", reqId];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        //just set id, save context and return
        req = [NSEntityDescription insertNewObjectForEntityForName:@"Requirement" inManagedObjectContext:context];
        req.requirementID = reqId;
        //save context
        [Requirement saveContext:context];
    } else {
        //if already exists, return
        req  = [matches lastObject];
    }
    
    //return
    return req;
}

+ (NSArray *)getAllStoredRequirementsForProject:(NSString *)projectId fromManagedObjectContext:(NSManagedObjectContext *)context
{
    //get all projects from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Requirement"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
    
}

- (Requirement *)copy
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Requirement" inManagedObjectContext:self.managedObjectContext];
    Requirement *output = (Requirement *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    output.requirementID = self.requirementID;
    output.name = self.name;
    output.linkedWith = [self.linkedWith copy];
    return output;
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
