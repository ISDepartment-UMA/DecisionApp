//
//  SuperCharacteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SuperCharacteristic.h"

@interface SuperCharacteristic (Factory)
+ (SuperCharacteristic *)addNewSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight toComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context;
@end
