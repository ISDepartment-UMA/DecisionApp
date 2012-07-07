//
//  Component.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, SuperCharacteristic;

@interface Component : NSManagedObject

@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) Project *partOf;
@property (nonatomic, retain) NSSet *ratedBy;
@end

@interface Component (CoreDataGeneratedAccessors)

- (void)addRatedByObject:(SuperCharacteristic *)value;
- (void)removeRatedByObject:(SuperCharacteristic *)value;
- (void)addRatedBy:(NSSet *)values;
- (void)removeRatedBy:(NSSet *)values;

@end
