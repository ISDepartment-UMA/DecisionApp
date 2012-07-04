//
//  Characteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Characteristic.h"

@interface Characteristic (Factory)
+ (Characteristic *)addNewCharacteristic:(NSString *)characteristicName withValue:(NSNumber *)value toSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight andComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context;
@end
