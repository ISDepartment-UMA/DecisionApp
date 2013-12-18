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

@property (strong, nonatomic) NSArray *selectedProject;
@property (strong, nonatomic) NSArray *availableProjects;
@property (nonatomic) BOOL timerHasStoped;

@end

@implementation ProjectPlatformModel
@synthesize selectedProject = _selectedProject;
@synthesize availableProjects = _availableProjects;
@synthesize timerHasStoped = _timerHasStoped;

- (NSArray *)getSelectedProject
{
    return _selectedProject;
}
- (void)setSelectedProject:(NSArray *)projectArray
{
    _selectedProject = [projectArray copy];
}


- (ProjectPlatformModel *)init
{
    //initialize
    self = [super init];
    return self;
}




#pragma mark - WebService Methods

- (NSArray *)getAllProjectsNamesAndSetDelegate:(id<ProjectPlatformModelDelegate>)delegate
{
    //get projects from core database
    NSArray *storedProjects = [self getStoredProjects];
    //get projects from webservice
    NSArray *webServiceProjects = [WebServiceConnector getAllProjectNames];
    
    //timeout occurred or not
    if (!webServiceProjects) {
        //keep trying and return stored projects
        [NSThread detachNewThreadSelector:@selector(retryConnectionToWebServiceAndAlertDelegate:) toTarget:self withObject:delegate];
        NSArray *output = [NSArray arrayWithObjects:storedProjects, [NSArray array], nil];
        return output;
        
    } else {
        //merge stored projects and projects from webservice
        return [self mergeProjectsFromWebService:webServiceProjects andCoreDatabase:storedProjects];
    }
}

- (NSArray *)mergeProjectsFromWebService:(NSArray *)pWebService andCoreDatabase:(NSArray *)pCoreData
{
    NSMutableArray *mutableArray = [pWebService mutableCopy];
    //eliminate projects that are already stored on the device
    for (NSArray *project in pWebService) {
        if ([Project getProjectForId:[project objectAtIndex:0] fromManagedObjectContext:self.managedObjectContext]) {
            [mutableArray removeObject:project];
        }
    }
    //combine arrays and return
    pWebService = [mutableArray copy];
    NSArray *output = [NSArray arrayWithObjects:pCoreData, pWebService, nil];
    return output;
}

/*
 permenantly looks for a connection to retrieve projects from the webservice
 until projects have been found or the delegate is does not need them any more
 if connection works, the delegate is alerted
 */
- (void)retryConnectionToWebServiceAndAlertDelegate:(id<ProjectPlatformModelDelegate>)delegate
{
    NSArray *webServiceProjects = nil;
    while (([delegate projectPlatformModelShouldKeepRetryingConnection]) && !webServiceProjects) {
        webServiceProjects = [WebServiceConnector getAllProjectNames];
        if (webServiceProjects) {
            //get projects from core database
            NSArray *storedProjects = [self getStoredProjects];
            NSArray *output = [self mergeProjectsFromWebService:webServiceProjects andCoreDatabase:storedProjects];
            [delegate projectArrayDidChange:output];
        }
    }
}



#pragma mark - Core Data Methods

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
