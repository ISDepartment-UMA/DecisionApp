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
        
        
    } else {
        superChar = [matches lastObject];
    }
    
    return superChar;
    
    
}


@end
