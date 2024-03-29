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
        
        [AvailableCharacteristic saveContext:context];

    } else {
        aC = [matches lastObject];
    }
    
    return aC;
    
    
}

+ (BOOL)replaceAvailableCharacteristic:(NSString *)characteristicName withAvailableCharacteristic:(NSString *)newCharacteristicName inManagedObjectContext:(NSManagedObjectContext *)context
{
    AvailableCharacteristic *aC = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableCharacteristic"];
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", characteristicName];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 1) {
        return NO;
    } else {
        aC = [matches lastObject];
        aC.name = newCharacteristicName;
        return [AvailableCharacteristic saveContext:context];
    }
    
}

//delete available characteristic with name
+ (BOOL)deleteAvailableCharacteristicNamed:(NSString *)name fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableCharacteristic"];
    //look for
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", name];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //delete characteristic
    [context deleteObject:[matches objectAtIndex:0]];
    //save context
    return [AvailableCharacteristic saveContext:context];
}


+ (NSArray *)getAllAvailableSuperCharacteristicsFromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
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
