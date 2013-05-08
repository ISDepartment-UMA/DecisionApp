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
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "WebServiceConnector.h"

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
    self.project = [self initializeProjectFromID:idOfProject toManagedObjectContext:self.managedObjectContext];
    return self;
}

//prepares the core database for the rating of the project and returns a 2 dimensional array
//1st dimension: - 0 for supercharacteristics names - 1 for subcharacteristics names of supercharacteristic at value of 0
- (Project *)initializeProjectFromID:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *matches = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:context];

    
    //initialize arrays for super- and subcharacteristics
    NSMutableArray *superchar = [NSMutableArray array];
    NSMutableArray *subchar = [NSMutableArray array];
    
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //add name of supercharacteristic to array of supercharacteristics
        [superchar addObject:tmpasc.name];
        
        
        //prepare array for names of subcharacteristics
        NSMutableArray *tmp = [NSMutableArray array];
        
        //iterate through subcharacteristics
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *enumerator = [tmpasc.availableSuperCharacteristicOf sortedArrayUsingDescriptors:descriptors];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            
            //add name of subcharacteristic to array of subcharacteristics
            [tmp addObject:tmpcharacteristic.name];
            
            
            //iterate through all components of the project and add this characteristic to it
            NSArray *componentsOfProject = [WebServiceConnector getAllComponentsForProjectId:projectID];
            
            for (int y=0; y<[componentsOfProject count]; y++) {
                NSString *componentID = [[componentsOfProject objectAtIndex:y] objectAtIndex:0];
                [Characteristic addNewCharacteristic:tmpcharacteristic.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:tmpasc.name withWeight:[NSNumber numberWithInt:3] andComponent:componentID andProject:projectID andManagedObjectContext:context];
            }
            
            
        }
        
        //add array of subcharacteristics to the array of subcharacteristics
        [subchar addObject:tmp];
    }
                        
    
    return [Project getProjectForId:projectID fromManagedObjectContext:context];
    
    
    

    
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
