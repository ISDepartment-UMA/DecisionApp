//
//  Characteristic+Factory.m
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
@implementation Characteristic (Factory)

+ (Characteristic *)addNewCharacteristic:(NSString *)characteristicName withValue:(NSNumber *)value toSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight andComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context
{
    Characteristic *characteristic = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Characteristic"];
    request.predicate = [NSPredicate predicateWithFormat:@"name =%@", characteristicName];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        return nil;
    } else if ([matches count] == 0) {
        
        //add new entity of SuperCharacteristic and set the name
        characteristic = [NSEntityDescription insertNewObjectForEntityForName:@"Characteristic" inManagedObjectContext:context];
        characteristic.name = characteristicName;
        characteristic.id = @"";
        characteristic.value = value;
        characteristic.weight = nil;
        characteristic.hasSuperCharacteristic = [SuperCharacteristic addNewSuperCharacteristic:superCharacteristicName withWeight:weight toComponent:componentID andProject:projectID andManagedObjectContext:context];
        
        
    } else {
        characteristic = [matches lastObject];
    }
    
    return characteristic;
    
    
}
@end
