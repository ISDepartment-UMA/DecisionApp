//
//  Component+Factory.m
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Component+Factory.h"
#import "Project+Factory.h"
#import "SBJson.h"
#import "WebServiceConnector.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"

@implementation Component (Factory)

+ (Component *)addNewComponent:(NSString *)componentID toProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Component *comp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        comp = [NSEntityDescription insertNewObjectForEntityForName:@"Component" inManagedObjectContext:context];
        comp.componentID = componentID;
        comp.projectID = projectID;
        
        NSDictionary *componentInfo = [WebServiceConnector getComponentForID:componentID];
        comp.name = [componentInfo objectForKey:@"name"];
        comp.descr = [componentInfo objectForKey:@"description"];
        comp.priority = [componentInfo objectForKey:@"priority"];
        
        //estimated hours passed as string --> NSNumber in database
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *hours = [f numberFromString:[componentInfo objectForKey:@"estimatedhours"]];
        comp.estimatedhours = hours;
        
        
        comp.shortdescr = [componentInfo objectForKey:@"shortdescription"];
        comp.modifier = [componentInfo objectForKey:@"modifier"];
        comp.partOf = [Project addNewProject:projectID toManagedObjectContext:context withTimestamp:nil];
        
        
        
        //save context
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        
    } else {
        comp = [matches lastObject];
    }
                       
return comp;
                       
                       
}

+ (Component *)getComponentForId:(NSString *)componentID fromManagedObjectContext:(NSManagedObjectContext *)context
{
    //retrieving the rating values
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    request.predicate = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return [matches lastObject];
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

+ (BOOL)removeSuperCharacteristicWithName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Component *comp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    request.predicate = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 1) {
        return NO;
    } else {
        
        //delete
        comp = [matches lastObject];
        SuperCharacteristic *superCharToDelete;
        for (SuperCharacteristic *superChar in comp.ratedBy) {
            if ([superChar.name isEqualToString:superCharName]) {
                superCharToDelete = superChar;
            }
        }
        
        if (superCharToDelete) {
            [comp removeRatedByObject:superCharToDelete];
        } else {
            return NO;
        }
        
        //save context
        if (![self saveContext:context]) {
            return NO;
        }
        
        return YES;
    }
}


+ (BOOL)removeCharacteristicWithName:(NSString *)charName andSuperCharName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Component *comp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    request.predicate = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 1) {
        return NO;
    } else {
        
        //delete
        comp = [matches lastObject];
        
        for (SuperCharacteristic *superChar in comp.ratedBy) {
            if ([superChar.name isEqualToString:superCharName]) {
                
                Characteristic *characteristicToDelete = nil;
                for (Characteristic *characteristic in superChar.superCharacteristicOf) {
                    if ([characteristic.name isEqualToString:charName]) {
                        characteristicToDelete = characteristic;
                        break;
                    }
                }
                if (characteristicToDelete) {
                    [superChar removeSuperCharacteristicOfObject:characteristicToDelete];
                } else {
                    return NO;
                }
                
                break;
            }
        }
        
        
        
        //save context
        if (![self saveContext:context]) {
            return NO;
        }
        
        return YES;
    }
}



@end
