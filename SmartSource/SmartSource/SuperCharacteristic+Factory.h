//
//  SuperCharacteristic+Factory.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SuperCharacteristic.h"
#import "Project.h"

@interface SuperCharacteristic (Factory)

+ (SuperCharacteristic *)addNewSuperCharacteristic:(NSString *)superCharacteristicName withWeight:(NSNumber *)weight toComponent:(NSString *)componentID andProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)saveWeight:(NSNumber *)weight forSuperCharacteristic:(NSString *)superChar inProject:(Project *)project andManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteSuperCharacteristicWithName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)replaceSupercharacteristic:(NSString *)supercharacteristicName withSupercharacteristic:(NSString *)newSupercharacteristicName inEveryProjectinManagedObjectContext:(NSManagedObjectContext *)context;
@end
