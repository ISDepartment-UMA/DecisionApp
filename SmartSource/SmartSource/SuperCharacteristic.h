//
//  SuperCharacteristic.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Characteristic, Component;

@interface SuperCharacteristic : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * componentID;
@property (nonatomic, retain) Component *rates;
@property (nonatomic, retain) NSSet *superCharacteristicOf;
@end

@interface SuperCharacteristic (CoreDataGeneratedAccessors)

- (void)addSuperCharacteristicOfObject:(Characteristic *)value;
- (void)removeSuperCharacteristicOfObject:(Characteristic *)value;
- (void)addSuperCharacteristicOf:(NSSet *)values;
- (void)removeSuperCharacteristicOf:(NSSet *)values;

@end
