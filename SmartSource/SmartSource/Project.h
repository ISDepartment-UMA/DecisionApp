//
//  Project.h
//  SmartSource
//
//  Created by Lorenz on 11.09.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Component;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * enddate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSString * startdate;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * weightingHasBeenEdited;
@property (nonatomic, retain) NSSet *consistsOf;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addConsistsOfObject:(Component *)value;
- (void)removeConsistsOfObject:(Component *)value;
- (void)addConsistsOf:(NSSet *)values;
- (void)removeConsistsOf:(NSSet *)values;

@end
