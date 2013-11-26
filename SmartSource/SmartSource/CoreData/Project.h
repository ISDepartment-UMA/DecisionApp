//
//  Project.h
//  SmartSource
//
//  Created by Lorenz on 14.11.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Component, Requirement;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * enddate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pathReportPdf;
@property (nonatomic, retain) NSString * projectID;
@property (nonatomic, retain) NSString * startdate;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * weightingHasBeenEdited;
@property (nonatomic, retain) NSSet *consistsOf;
@property (nonatomic, retain) NSSet *hasRequirements;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addConsistsOfObject:(Component *)value;
- (void)removeConsistsOfObject:(Component *)value;
- (void)addConsistsOf:(NSSet *)values;
- (void)removeConsistsOf:(NSSet *)values;

- (void)addHasRequirementsObject:(Requirement *)value;
- (void)removeHasRequirementsObject:(Requirement *)value;
- (void)addHasRequirements:(NSSet *)values;
- (void)removeHasRequirements:(NSSet *)values;

@end
