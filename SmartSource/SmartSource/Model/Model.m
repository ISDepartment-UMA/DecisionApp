//
//  Model.m
//  SmartSource
//
//  Created by Lorenz on 18.12.13.
//
//

#import "Model.h"
#import "SmartSourceAppDelegate.h"

@interface Model ()

@end

@implementation Model
@synthesize managedObjectContext = _managedObjectContext;

/*
 *  init model and retrieve managed object context from SmartSourceAppDelegate
 *
 */
- (Model *)init
{
    self = [super init];
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    return self;
}


/*
 *  save context using the context
 *
 */
- (BOOL)saveContext
{
    //save context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        return NO;
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } else {
        return YES;
    }
}

@end
