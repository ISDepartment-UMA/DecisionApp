//
//  ProjectPlatformModel.m
//  SmartSource
//
//  Created by Lorenz on 08.05.13.
//
//

#import "ProjectPlatformModel.h"
#import "SmartSourceAppDelegate.h"
#import "WebServiceConnector.h"
#import "Project+Factory.h"
#import "Characteristic.h"
#import "SuperCharacteristic.h"
#import "Component.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"

@interface ProjectPlatformModel()

@property (strong, nonatomic) NSArray *allProjects;
@property (strong, nonatomic) NSArray *selectedProject;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation ProjectPlatformModel
@synthesize allProjects = _allProjects;
@synthesize selectedProject = _selectedProject;
@synthesize managedObjectContext = _managedObjectContext;

- (NSArray *)getSelectedProject
{
    return _selectedProject;
}
- (void)setSelectedProject:(NSArray *)projectID
{
    _selectedProject = [projectID copy];
}


- (ProjectPlatformModel *)init
{
    //initialize
    self = [super init];
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    return self;
}

- (NSArray *)getAllProjectNames
{
    return [WebServiceConnector getAllProjectNames];
}

- (NSArray *)getProjectInfo:(NSString *)projectID
{
    return [WebServiceConnector getProjectInfoArray:projectID];
}








- (NSArray *)getStoredProjects
{
    
    
    NSArray *matches = [Project getStoredAllStoredProjectsFromManagedObjectContext:self.managedObjectContext];
    
    //initiate array of available projects
    NSMutableArray *availableProjects = [NSMutableArray array];
    
    //put id, name and description of all projects into available projects
    for (int i=0; i<[matches count]; i++) {
        Project *currProject = [matches objectAtIndex:i];
        [availableProjects addObject:[NSArray arrayWithObjects:currProject.projectID, currProject.name, currProject.descr, nil]];
    }
    
    return [availableProjects copy];
}


- (void)deleteProjectWithID:(NSString *)projectID
{
    [Project deleteProjectWithID:projectID fromManagedObjectContext:self.managedObjectContext];
}



//checks weather the rating of the currently displayed project is complete or not
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID
{
    
    Project *project = [Project getProjectForId:projectID fromManagedObjectContext:self.managedObjectContext];
    
    if (!project) {
        return NO;
    }
    
    NSEnumerator *componentEnumerator = [project.consistsOf objectEnumerator];
    
    //iterate through components
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        
        //iterate through all SuperCharacteristics
        SuperCharacteristic *superChar;
        NSEnumerator *superCharEnumerator = [comp.ratedBy objectEnumerator];
        while ((superChar = [superCharEnumerator nextObject]) != nil) {
            
            //iterate through all characteristics and add their values to the value of supercharacteristic
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superChar.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                if ([characteristic.value intValue] == 0) {
                    NSLog(@"hier");
                    return NO;
                }
            }
        }
    }
    
    return YES;
    
}


- (BOOL)ratingCharacteristicsHaveChangedForProject:(NSString *)projectID
{
    NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
    Project *project = [Project getProjectForId:projectID fromManagedObjectContext:self.managedObjectContext];
    if (!project) {
        return false;
    }
    
    Component *component = [[project.consistsOf objectEnumerator] nextObject];
    
    //availablesupercharacteristics
    for (AvailableSuperCharacteristic *availableSuperChar in availableSuperCharacteristics) {
        
        //check if all available supercharacteristics have been used in the component
        bool foundAvailableSuperChar = false;
        //iterate used supercharacteristics
        for (SuperCharacteristic *usedSuperChar in component.ratedBy) {
            if ([usedSuperChar.name isEqualToString:availableSuperChar.name]) {
                //found
                foundAvailableSuperChar = true;
                
                //check if all available characteristics of a used supercharacteristics have been used
                for (AvailableCharacteristic *availableCharacteristic in availableSuperChar.availableSuperCharacteristicOf) {
                    bool foundAvailableChar = false;
                    //iterate 
                    for (Characteristic *usedCharacteristic in usedSuperChar.superCharacteristicOf) {
                        if ([usedCharacteristic.name isEqualToString:availableCharacteristic.name]) {
                            //found
                            foundAvailableChar = true;
                        }
                    }
                    
                    if (!foundAvailableChar) {
                        return true;
                    }
                }
            }
        }
        if (!foundAvailableSuperChar) {
            return true;
            
        }
    }
    return NO;
}

@end
