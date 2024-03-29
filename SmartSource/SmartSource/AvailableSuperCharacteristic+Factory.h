//
//  AvailableSuperCharacteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvailableSuperCharacteristic.h"

@interface AvailableSuperCharacteristic (Factory)
+ (AvailableSuperCharacteristic *)addNewAvailableSuperCharacteristic:(NSString *)name toManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllAvailableSuperCharacteristicsFromManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)replaceAvailableSuperCharacteristic:(NSString *)supercharacteristicName withAvailableCharacteristic:(NSString *)newSupercharacteristicName inManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteAvailableSuperCharacteristicNamed:(NSString *)name fromManagedObjectContext:(NSManagedObjectContext *)context;
@end
