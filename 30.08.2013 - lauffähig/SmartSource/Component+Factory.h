//
//  Component+Factory.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Component.h"

@interface Component (Factory)
+ (Component *)addNewComponent:(NSString *)componentID toProject:(NSString *)projectID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (Component *)getComponentForId:(NSString *)componentID fromManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)saveContext:(NSManagedObjectContext *)context;
+ (BOOL)removeCharacteristicWithName:(NSString *)charName andSuperCharName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)removeSuperCharacteristicWithName:(NSString *)superCharName fromComponentWithId:(NSString *)componentID andManagedObjectContext:(NSManagedObjectContext *)context;
@end
