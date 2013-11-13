//
//  Characteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Characteristic.h"

@interface Characteristic (Factory)
+ (Characteristic *)addNewCharacteristic:(NSString *)characteristicName withValue:(NSNumber *)value toSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight andComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)getCharacteristicsForComponentId:(NSString *)componentID fromManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteCharacteristicWithName:(NSString *)charName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)replaceCharacteristic:(NSString *)characteristicName withCharacteristic:(NSString *)newCharacteristicName inEveryProjectinManagedObjectContext:(NSManagedObjectContext *)context;

@end
