//
//  Requirement+Factory.h
//  SmartSource
//
//  Created by Lorenz on 14.11.13.
//
//

#import "Requirement.h"

@interface Requirement (Factory)
+ (Requirement *)addNewRequirementWithId:(NSString *)reqId andName:(NSString *)name andLinkedRequirements:(NSArray *)linkedRequirements andLinkedComponents:(NSArray *)linkedComponents andProjectId:(NSString *)projectId toManagedObjectContext:(NSManagedObjectContext *)context;
+ (Requirement *)addNewRequirementWithId:(NSString *)reqId toManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)getAllStoredRequirementsForProject:(NSString *)projectId fromManagedObjectContext:(NSManagedObjectContext *)context;
- (Requirement *)copy;
@end
