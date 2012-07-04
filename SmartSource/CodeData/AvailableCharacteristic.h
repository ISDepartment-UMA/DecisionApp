//
//  AvailableCharacteristic.h
//  SmartSource
//
//  Created by Lorenz on 26.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AvailableSuperCharacteristic;

@interface AvailableCharacteristic : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) AvailableSuperCharacteristic *hasAvailableSuperCharacteristic;

@end
