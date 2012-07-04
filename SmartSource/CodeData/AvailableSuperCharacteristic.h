//
//  AvailableSuperCharacteristic.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AvailableCharacteristic;

@interface AvailableSuperCharacteristic : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *availableSuperCharacteristicOf;
@end

@interface AvailableSuperCharacteristic (CoreDataGeneratedAccessors)

- (void)addAvailableSuperCharacteristicOfObject:(AvailableCharacteristic *)value;
- (void)removeAvailableSuperCharacteristicOfObject:(AvailableCharacteristic *)value;
- (void)addAvailableSuperCharacteristicOf:(NSSet *)values;
- (void)removeAvailableSuperCharacteristicOf:(NSSet *)values;

@end
