//
//  SuperCharacteristic+Factory.m
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SuperCharacteristic+Factory.h"
#import "Component+Factory.h"
#import "SBJson.h"
#import "Project.h"

@implementation SuperCharacteristic (Factory)

+ (SuperCharacteristic *)addNewSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight toComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context
{
    SuperCharacteristic *superChar = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", superCharacteristicName];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, predicate3, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {        
        //add new entity of SuperCharacteristic and set the name
        superChar = [NSEntityDescription insertNewObjectForEntityForName:@"SuperCharacteristic" inManagedObjectContext:context];
        superChar.name = superCharacteristicName;
        superChar.projectID = projectID;
        superChar.weight = weight;
        superChar.componentID = componentID;
        superChar.rates = [Component addNewComponent:componentID toProject:projectID andManagedObjectContext:context];
        
        //save context
        [SuperCharacteristic saveContext:context];
        
    } else {
        superChar = [matches lastObject];
    }
    
    return superChar;
    
    
}

+ (void)saveWeight:(NSNumber *)weight forSuperCharacteristic:(NSString *)superChar inProject:(Project *)project andManagedObjectContext:(NSManagedObjectContext *)context
{
    //store value
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", superChar];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", project.projectID];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    //set weight of this supercharacteristic for ALL COMPONENTS of the current project
    for (SuperCharacteristic *rightSuperCharacteristic in matches) {
        rightSuperCharacteristic.weight = weight;
    }
    //save context
    [SuperCharacteristic saveContext:context];
    
}

+ (BOOL)deleteSuperCharacteristicWithName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context
{
    SuperCharacteristic *superChar = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", superCharName];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"componentID =%@", componentID];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate3, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] == 1) {
        superChar = [matches lastObject];
        [context deleteObject:superChar];
        return [SuperCharacteristic saveContext:context];
    } else {
        return NO;
    }    
}

+ (BOOL)replaceSupercharacteristic:(NSString *)supercharacteristicName withSupercharacteristic:(NSString *)newSupercharacteristicName inEveryProjectinManagedObjectContext:(NSManagedObjectContext *)context
{
    //get all supercharacteristics with the name, no matter which project
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", supercharacteristicName];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //rename them and save context
    if ([matches count] > 0) {
        for (SuperCharacteristic *charact in matches) {
            charact.name = newSupercharacteristicName;
        }
        return [SuperCharacteristic saveContext:context];
    } else {
        return NO;
    }
}

//save context in current managed object context
+ (BOOL)saveContext:(NSManagedObjectContext *)context
{
    //save context
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        return NO;
    } else  {
        return YES;
    }
}


@end
