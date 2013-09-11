//
//  AvailableCharacteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AvailableCharacteristic.h"

@interface AvailableCharacteristic (Factory)
+ (AvailableCharacteristic *)addNewAvailableCharacteristic:(NSString *)name toSuperCharacteristic:(NSString *)name toManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)replaceAvailableCharacteristic:(NSString *)characteristicName withAvailableCharacteristic:(NSString *)newCharacteristicName inManagedObjectContext:(NSManagedObjectContext *)context;
@end
