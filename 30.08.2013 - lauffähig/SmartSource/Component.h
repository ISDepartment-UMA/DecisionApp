//
//  Component.h
//  SmartSource
//
//  Created by Lorenz on 12.07.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Project, SuperCharacteristic;

@interface Component : NSManagedObject

@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSNumber * estimatedhours;
@property (nonatomic, retain) NSString * componentID;
@property (nonatomic, retain) NSString * modifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSString * shortdescr;
@property (nonatomic, retain) Project *partOf;
@property (nonatomic, retain) NSSet *ratedBy;
@end

@interface Component (CoreDataGeneratedAccessors)

- (void)addRatedByObject:(SuperCharacteristic *)value;
- (void)removeRatedByObject:(SuperCharacteristic *)value;
- (void)addRatedBy:(NSSet *)values;
- (void)removeRatedBy:(NSSet *)values;

@end
