//
//  Model.h
//  SmartSource
//
//  Created by Lorenz on 18.12.13.
//
//

#import <Foundation/Foundation.h>

@interface Model : NSObject
//context
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//save context
- (BOOL)saveContext;
@end
