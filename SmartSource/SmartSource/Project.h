//
//  Project.h
//  SmartSource
//
//  Created by Lorenz on 05.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Component;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *consistsOf;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addConsistsOfObject:(Component *)value;
- (void)removeConsistsOfObject:(Component *)value;
- (void)addConsistsOf:(NSSet *)values;
- (void)removeConsistsOf:(NSSet *)values;

@end
