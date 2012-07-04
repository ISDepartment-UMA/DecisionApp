//
//  AvailableSuperCharacteristic+Factory.m
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvailableSuperCharacteristic+Factory.h"
#import "AvailableCharacteristic+Factory.h"

@implementation AvailableSuperCharacteristic (Factory)

+ (AvailableSuperCharacteristic *)addNewAvailableSuperCharacteristic:(NSString *)name toManagedObjectContext:(NSManagedObjectContext *)context
{
    AvailableSuperCharacteristic *aSC = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", name];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        aSC = [NSEntityDescription insertNewObjectForEntityForName:@"AvailableSuperCharacteristic" inManagedObjectContext:context];
        aSC.name = name;
        aSC.id = @"";
    } else {
        aSC = [matches lastObject];
    }
    
    return aSC;
    
    
}

@end
