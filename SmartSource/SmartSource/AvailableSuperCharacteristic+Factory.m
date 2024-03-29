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
        //save context
        [AvailableSuperCharacteristic saveContext:context];
    } else {
        aSC = [matches lastObject];
    }
    
    return aSC;
    
    
}

+ (NSArray *)getAllAvailableSuperCharacteristicsFromManagedObjectContext:(NSManagedObjectContext *)context
{
    //
    //getting characteristics from core database
    //get all supercharacteristics
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    return matches;
}

+ (BOOL)replaceAvailableSuperCharacteristic:(NSString *)supercharacteristicName withAvailableCharacteristic:(NSString *)newSupercharacteristicName inManagedObjectContext:(NSManagedObjectContext *)context
{
    AvailableSuperCharacteristic *aSC = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", supercharacteristicName];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if ([matches count] != 1) {
        return NO;
    } else {
        aSC = [matches lastObject];
        aSC.name = newSupercharacteristicName;
        return [AvailableSuperCharacteristic saveContext:context];
    }
    
}

//delete available supercharacteristic with name
//cascade will delete all characteristics that belong to it
+(BOOL)deleteAvailableSuperCharacteristicNamed:(NSString *)name fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    //look for
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", name];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    //delete characteristic
    [context deleteObject:[matches objectAtIndex:0]];
    return [AvailableSuperCharacteristic saveContext:context];
    

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
