//
//  ProjectModel.m
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import "ProjectModel.h"
#import "Project+Factory.h"
#import "Component+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "SmartSourceAppDelegate.h"

@interface ProjectModel ()
@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@end

@implementation ProjectModel

//synthesize
@synthesize project = _project;
@synthesize managedObjectContext = _managedObjectContext;


//constructor that initializes the projectmodel and prepares the core database for the rating
- (ProjectModel *)initWithProjectID:(NSString *)idOfProject
{
    self = [super init];
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.project = [Project initProjectFromID:idOfProject toManagedObjectContext:self.managedObjectContext];
    return self;
}


//returns an array of all components in project in alphabetical order
- (NSArray *)arrayWithComponents
{
    return [self.project.consistsOf sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}


//returns the number of components of the project
- (NSInteger)numberOfComponents
{
    return [self.project.consistsOf count];
    
}

//checks weather the rating of the project is complete or not
- (BOOL)ratingIsComplete
{
    
    Project *project = self.project;
    NSEnumerator *componentEnumerator = [project.consistsOf objectEnumerator];
    
    //iterate through components
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        
        
        //iterate through all supercharacteristics
        SuperCharacteristic *superCharacteristic;
        NSEnumerator *superCharacteristicEnumerator = [comp.ratedBy objectEnumerator];
        
        while ((superCharacteristic = [superCharacteristicEnumerator nextObject]) != nil) {
            
            //iterate through all characteristics and check if one of them hasn't been rated yet (value == 0)
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superCharacteristic.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                if ([characteristic.value intValue] == 0) {
                    return NO;
                }
            }
        }
        
    }
    
    return YES;
    
}


- (NSString *) getID
{
    return self.project.projectID;
}



@end
