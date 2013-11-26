//
//  Requirement.h
//  SmartSource
//
//  Created by Lorenz on 16.11.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Component, Project, Requirement;

@interface Requirement : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * requirementID;
@property (nonatomic, retain) Project *linkedProject;
@property (nonatomic, retain) NSSet *linkedWith;
@property (nonatomic, retain) NSSet *linkedComponents;
@end

@interface Requirement (CoreDataGeneratedAccessors)

- (void)addLinkedWithObject:(Requirement *)value;
- (void)removeLinkedWithObject:(Requirement *)value;
- (void)addLinkedWith:(NSSet *)values;
- (void)removeLinkedWith:(NSSet *)values;

- (void)addLinkedComponentsObject:(Component *)value;
- (void)removeLinkedComponentsObject:(Component *)value;
- (void)addLinkedComponents:(NSSet *)values;
- (void)removeLinkedComponents:(NSSet *)values;

@end
