//
//  AvailableCharacteristic+Factory.m
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"

@implementation AvailableCharacteristic (Factory)


+ (AvailableCharacteristic *)addNewAvailableCharacteristic:(NSString *)name toSuperCharacteristic:(NSString *)superName toManagedObjectContext:(NSManagedObjectContext *)context
{
    AvailableCharacteristic *aC = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableCharacteristic"];
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", name];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        //handle error
    } else if ([matches count] == 0) {
        aC = [NSEntityDescription insertNewObjectForEntityForName:@"AvailableCharacteristic" inManagedObjectContext:context];
        aC.name = name;
        aC.hasAvailableSuperCharacteristic = [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:superName toManagedObjectContext:context];
        aC.id = @"";
        
        

    } else {
        aC = [matches lastObject];
    }
    
    return aC;
    
    
}


@end
