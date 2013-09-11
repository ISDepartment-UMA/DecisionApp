//
//  Characteristic.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SuperCharacteristic;

@interface Characteristic : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSString * componentID;
@property (nonatomic, retain) SuperCharacteristic *hasSuperCharacteristic;

@end
