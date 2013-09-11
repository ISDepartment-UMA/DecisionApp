//
//  ProjectModel.m
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import "ProjectModel.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "SmartSourceAppDelegate.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "WebServiceConnector.h"

@interface ProjectModel ()
@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *classificationResult;


//for results
@property (nonatomic) float totalWeightOfSuperCharacteristics;

//for decision table
@property (strong, nonatomic) NSDictionary *superCharValueDic;



@end

@implementation ProjectModel
@synthesize totalWeightOfSuperCharacteristics = _totalWeightOfSuperCharacteristics;

//synthesize
@synthesize project = _project;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize superCharValueDic = _superCharValueDic;

#pragma mark -  Evaluation Results

/* returns components of A, B or C components of the current classification
 A -- @"A - Components"
 */
- (NSArray *)getComponentsForCategory:(NSString *)category
{
    if ([category isEqualToString:@"A - Components"]) {
        return [self.classificationResult objectAtIndex:0];
    } else if ([category isEqualToString:@"B - Components"]){
        return [self.classificationResult objectAtIndex:1];
    } else if ([category isEqualToString:@"C - Components"]){
        return [self.classificationResult objectAtIndex:2];
    } else {
        return [NSArray array];
    }
    
}



//public method to get the project
- (Project *)getProjectObject
{
    return self.project;
}


//method that calculates the results of the evaluation
- (NSArray *)calculateResults
{
    
    //calculate results again every time
    //if it already exiists, just return
    /*
    if (self.classificationResult) {
        return self.classificationResult;
    }*/
    
    //otherwise calculate....
    
    
    //iterate through components
    NSEnumerator *componentEnumerator = [self.project.consistsOf objectEnumerator];
    NSArray *classification = [NSArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        
        //initiate array for rating values of supercharacteristics
        NSMutableArray *ratingValuesSuperChar = [NSMutableArray array];
        
        
        //iterate through all SuperCharacteristics to get their weighted rating value and add up the total weight of all supercharacteristics
        double totalWeight = 0.0;
        SuperCharacteristic *superChar;
        NSEnumerator *superCharEnumerator = [comp.ratedBy objectEnumerator];
        while ((superChar = [superCharEnumerator nextObject]) != nil) {
            
            //initiate rating value for supercharacteristic
            float valueOfSuperCharacteristic = 0.0;
            
            //iterate through all characteristics and add their values to the value of supercharacteristic
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superChar.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                valueOfSuperCharacteristic = valueOfSuperCharacteristic + [characteristic.value doubleValue];
            }
            
            //divide by number of characteristics --> average
            double numberOfCharacteristics = [[superChar superCharacteristicOf] count];
            valueOfSuperCharacteristic = (valueOfSuperCharacteristic/numberOfCharacteristics);
            
            
            //add weight to total weight of all supercharacteristics
            totalWeight = totalWeight + [superChar.weight doubleValue];
            
            //add weighted value to array
            double weightedValueofSuperCharacteristic = valueOfSuperCharacteristic * [superChar.weight doubleValue];
            [ratingValuesSuperChar addObject:[NSNumber numberWithDouble:weightedValueofSuperCharacteristic]];
            
        }
        
        self.totalWeightOfSuperCharacteristics = totalWeight;
        
        
        //build weighted average of the rating of ONE component
        NSArray *ratingValues = [ratingValuesSuperChar copy];
        double sum = 0.0;
        for (int i=0; i<[ratingValues count]; i++) {
            sum = sum + [[ratingValues objectAtIndex:i] doubleValue];
        }
        
        //calculate component weighted value
        double componentWeightedValue = (sum/totalWeight);
        
        
        //put component info into ABC-Classification according to its component weighted value
        // A <=> objectAtIndex 0, B <=> objectAtIndex 1, C <=> objectAtIndex 2
        if (componentWeightedValue < 1.67) {
            [[classification objectAtIndex:2] addObject:comp];
        } else if (componentWeightedValue < 2.34) {
            [[classification objectAtIndex:1] addObject:comp];
        } else if (componentWeightedValue <= 3.0) {
            [[classification objectAtIndex:0] addObject:comp];
        }
    }
    
    self.classificationResult = classification;
    return self.classificationResult;
}


- (Component *)getComponentObjectForID:(NSString *)componentID
{
    return [Component getComponentForId:componentID fromManagedObjectContext:self.managedObjectContext];
}

/*returns used characteristics and rating values of a component in a three-dimensional array
 
 first dimension:
 0 --> superchars with values
 1 --> chars with values
 
 second dimension:
 0 --> char
 1 --> value/weight
 
 */
- (NSArray *)getCharsAndValuesArray:(NSString *)componentID
{
    
    Component *comp = [Component getComponentForId:componentID fromManagedObjectContext:self.managedObjectContext];
    
    
    
    //initiate arrays of used supercharacteristics and characteristics
    NSMutableArray *usedSuperChars = [NSMutableArray array];
    NSMutableArray *usedChars = [NSMutableArray array];
    
    //initiate arrays for values
    NSMutableArray *valueSuperChars = [NSMutableArray array];
    NSMutableArray *valueChars = [NSMutableArray array];
    
    
    //iterate through all supercharacteristics
    SuperCharacteristic *superChar;
    
    //sort supercharacteristics
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSEnumerator *superCharEnumerator = [[comp.ratedBy sortedArrayUsingDescriptors:descriptors] objectEnumerator];
    
    while ((superChar = [superCharEnumerator nextObject]) != nil) {
        
        //add supercharacteristic to used supercharacteristic array
        [usedSuperChars addObject:superChar.name];
        
        
        //add weight to array of supercharacteristic's values
        [valueSuperChars addObject:superChar.weight];
        
        //iterate through all characteristics of supercharacteristic
        Characteristic *characteristic;
        
        NSMutableArray *characteristicsOfSuperchar = [NSMutableArray array];
        NSMutableArray *valueOfCharacteristics = [NSMutableArray array];
        
        NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSEnumerator *charEnumerator = [[superChar.superCharacteristicOf sortedArrayUsingDescriptors:descriptors] objectEnumerator];
        
        while ((characteristic = [charEnumerator nextObject]) != nil) {
            
            //add characteristic to characteristic array
            [characteristicsOfSuperchar addObject:characteristic.name];
            
            //add characteristic value to array
            [valueOfCharacteristics addObject:characteristic.value];
        }
        
        //add array of characteristics to characteristics array
        [usedChars addObject:characteristicsOfSuperchar];
        [valueChars addObject:valueOfCharacteristics];
        
        
    }
    
    NSArray *output = [NSArray arrayWithObjects:[NSArray arrayWithObjects:[usedSuperChars copy], [valueSuperChars copy], nil], [NSArray arrayWithObjects:[usedChars copy], [valueChars copy], nil], nil];
    
    return output;
    
}

- (BOOL)ratingCharacteristicsHaveBeenAdded
{
    NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
    Component *component = [[self.project.consistsOf objectEnumerator] nextObject];
    
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
        
        //if supercharacteristic not in project AND IF SUPERCHARACTERISTIC HAS AT LEAST ONE SUBCHARACTERISTIC
        if ((!foundAvailableSuperChar) && ([availableSuperChar.availableSuperCharacteristicOf count] > 0)) {
            return true;
            
        }
    }
    
    return NO;
}

- (BOOL)ratingCharacteristicsHaveBeenDeleted
{
    
    NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
    Component *component = [[self.project.consistsOf objectEnumerator] nextObject];
    
    //iterate superchars used
    for (SuperCharacteristic *usedSuperChar in component.ratedBy) {
        //check if used superchars are still present in available superchars
        bool foundSuperChar = false;
        
        for (AvailableSuperCharacteristic *availableSuperChar in availableSuperCharacteristics) {
            if ([usedSuperChar.name isEqualToString:availableSuperChar.name]) {
                foundSuperChar = true;
                
                for (Characteristic *usedCharacteristic in usedSuperChar.superCharacteristicOf) {
                    bool foundCharacteristic = false;
                    
                    //iterate
                    for (AvailableCharacteristic *availableCharacteristic in availableSuperChar.availableSuperCharacteristicOf) {
                        if ([usedCharacteristic.name isEqualToString:availableCharacteristic.name]) {
                            //found
                            foundCharacteristic = true;
                        }
                    }
                    
                    if (!foundCharacteristic) {
                        return true;
                    }
                }
            }
            
            
            
        }
        
        if (!foundSuperChar) {
            return true;
            
        }
        
    }
    return NO;
}




//creates a table featuring all possible combinations of characteristics ratings and their result for the classification
- (NSArray *)getColumnsForDecisionTable
{
    Component *oneComponent = [self.project.consistsOf objectEnumerator].nextObject;
    
    //initiate coulmn array
    NSMutableArray *columns = [NSMutableArray array];
    double characteristicNumber = 0;
    double numberOfCombinations = pow(3, [oneComponent.ratedBy count]);
    
    //iterate through supercharacteristics
    SuperCharacteristic *currentSuperchar;
    NSEnumerator *superCharEnumerator = [oneComponent.ratedBy objectEnumerator];
    while ((currentSuperchar = [superCharEnumerator nextObject]) != nil) {
        
        //prepare array with all possible ratings of available characteristics
        NSMutableArray *tmp = [NSMutableArray array];
        
        while ([[tmp copy] count] <= numberOfCombinations) {
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:1]];
                }
            }
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:2]];
                }
            }
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:3]];
                }
            }
        }
        [columns addObject:[NSArray arrayWithObjects:currentSuperchar.name, currentSuperchar.weight, [tmp copy], nil]];
        characteristicNumber++;
        
    }
    
    //build the weighted average of all supercharacteristics and determine its ABC status
    //get the sum of all weights of supercharacteristics
    double sumWeight = 0;
    for (int i=0; i<[[columns copy] count]; i++) {
        sumWeight += [[[columns objectAtIndex:i] objectAtIndex:1] doubleValue];
    }
    
    //prepar rating array
    NSMutableArray *tmpWeightedValues = [NSMutableArray array];
    
    
    for (int i=0; i < [[[columns lastObject] objectAtIndex:2] count]; i++) {
        //get the sum of weighted ratings
        double sum = 0;
        for (int y=0; y<[columns count]; y++) {
            sum = sum + ([[[[columns objectAtIndex:y] objectAtIndex:2] objectAtIndex:i] intValue] * [[[columns objectAtIndex:y] objectAtIndex:1] intValue]);
        }
        
        //devide the sum of weighted ratings by the sum of weights
        double weightedValue = (sum/sumWeight);
        
        //--> weighted value
        if (weightedValue < 1.67) {
            [tmpWeightedValues addObject:@"OUTSOURCING"];
        } else if (weightedValue < 2.34) {
            [tmpWeightedValues addObject:@"INDIFFERENT"];
        } else if (weightedValue <= 3) {
            [tmpWeightedValues addObject:@"CORE"];
        }
        
        
        
        
    }
    
    NSArray *weightedValues = [NSArray arrayWithObjects:@"Weighted Value", @"", tmpWeightedValues, nil];
    [columns addObject:weightedValues];
    
    return [columns copy];
    
    
    
}

#pragma mark -  WebService

//prepares the core database for the rating of the project and returns a 2 dimensional array
//1st dimension: - 0 for supercharacteristics names - 1 for subcharacteristics names of supercharacteristic at value of 0
//this method uses the Core Data Classes as well as the WebService Connector class
- (Project *)initializeProjectFromID:(NSString *)projectID toManagedObjectContext:(NSManagedObjectContext *)context
{
    self.classificationResult = nil;
    
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
                NSString *componentID = [[componentsOfProject objectAtIndex:y] objectForKey:@"id"];
                [Characteristic addNewCharacteristic:tmpcharacteristic.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:tmpasc.name withWeight:[NSNumber numberWithInt:3] andComponent:componentID andProject:projectID andManagedObjectContext:context];
            }
            
            
        }
        
        //add array of subcharacteristics to the array of subcharacteristics
        [subchar addObject:tmp];
    }
    
    return [Project getProjectForId:projectID fromManagedObjectContext:context];
}


//retrieves project Information for a passed projectID
- (NSArray *)getProjectInfoArray
{
    Project *approProject = self.project;
    return [NSArray arrayWithObjects:self.project.projectID, approProject.name, approProject.descr, approProject.category, approProject.startdate, approProject.enddate, approProject.creator, nil];
    
    
}

#pragma mark - Core Data Methods


//constructor that initializes the projectmodel and prepares the core database for the rating
- (ProjectModel *)initWithProjectID:(NSString *)idOfProject
{
    self = [super init];
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

    //check if project is already in the database
    self.project = [Project getProjectForId:idOfProject fromManagedObjectContext:self.managedObjectContext];
    
    if (self.project != nil) {
        return self;
        
    //else, initialize model from webservice
    } else {
        self.project = [self initializeProjectFromID:idOfProject toManagedObjectContext:self.managedObjectContext];
        
        //if project is nil, there are no components in the project
        if (!self.project) {
            //write project into database without any components
            self.project = [Project addNewProject:idOfProject toManagedObjectContext:self.managedObjectContext withTimestamp:nil];
        }
        
        
        return self;
    }
    
}


- (ProjectModel *)updateCoreDataBaseForProjectID:(NSString *)projectID
{
    //additional characteristics
    if ([self ratingCharacteristicsHaveBeenAdded]) {
        
        //if there is a characteristic to add, supercharacteristic will be added automatically
        //a supercharacteristic without subcharacteristics is not relevant for rating
        NSMutableSet *characteristicsToAdd = [NSMutableSet set];
        
        NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
        Component *component = [[self.project.consistsOf objectEnumerator] nextObject];
        
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
                            [characteristicsToAdd addObject:availableCharacteristic];
                        }
                    }
                }
            }
            
            //if supercharacteristic has not been found, then add all subcharacteristics to project
            if (!foundAvailableSuperChar) {
                for (AvailableCharacteristic *subCharOfSuperCharToAdd in availableSuperChar.availableSuperCharacteristicOf) {
                    [characteristicsToAdd addObject:subCharOfSuperCharToAdd];
                }
            }
        }
        
        //immutable copy
        NSSet *charsToAdd = [characteristicsToAdd copy];
        //add additional characteristics to all components of the project
        for (Component *componentOfProject in self.project.consistsOf) {
            for (AvailableCharacteristic *charToAdd in charsToAdd) {
                //if database already contains 
                [Characteristic addNewCharacteristic:charToAdd.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:charToAdd.hasAvailableSuperCharacteristic.name withWeight:[NSNumber numberWithInt:3] andComponent:componentOfProject.componentID andProject:self.project.projectID andManagedObjectContext:self.managedObjectContext];
            }
        }
        
    


    }

    //characteristics do remove
    if ([self ratingCharacteristicsHaveBeenDeleted]) {
        
        NSMutableSet *characteristicsToDelete = [NSMutableSet set];
        NSMutableSet *superCharacteristicsToDelete = [NSMutableSet set];
        
        NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
        
        
        Component *component = [[self.project.consistsOf objectEnumerator] nextObject];
        for (SuperCharacteristic *usedSuperChar in component.ratedBy) {
            BOOL foundSuperChar = false;
            for (AvailableSuperCharacteristic *availableSuperChar in availableSuperCharacteristics) {
                if ([availableSuperChar.name isEqualToString:usedSuperChar.name]) {
                    foundSuperChar = true;
                    
                    for (Characteristic *usedChar in usedSuperChar.superCharacteristicOf) {
                        BOOL foundChar = false;
                        for (AvailableCharacteristic *availableChar in availableSuperChar.availableSuperCharacteristicOf) {
                            if ([availableChar.name isEqualToString:usedChar.name]) {
                                foundChar = true;
                            }
                        }
                        
                        if (!foundChar) {
                            [characteristicsToDelete addObject:usedChar];
                        }
                    }
                }
            }
            if (!foundSuperChar) {
                [superCharacteristicsToDelete addObject:usedSuperChar];
            }
        }
        
        NSSet *charsToDelete = [characteristicsToDelete copy];
        NSSet *superCharsToDelete = [superCharacteristicsToDelete copy];
        
        //delete
        for (Component *componentOfProject in self.project.consistsOf) {
            
            //delete supercharacteristics
            for (SuperCharacteristic *superChar in superCharsToDelete) {
                [Component removeSuperCharacteristicWithName:superChar.name fromComponentWithId:componentOfProject.componentID andManagedObjectContext:self.managedObjectContext];
            }
            
            //delete characteristics
            for (Characteristic *charToDelete in charsToDelete) {
                [Component removeCharacteristicWithName:charToDelete.name andSuperCharName:charToDelete.hasSuperCharacteristic.name fromComponentWithId:component.componentID andManagedObjectContext:self.managedObjectContext];
            }
            
            //delete superchars that do not have any chars any more
            for (SuperCharacteristic *usedSC in component.ratedBy) {
                if ([usedSC.superCharacteristicOf count] < 1) {
                    [Component removeSuperCharacteristicWithName:usedSC.name fromComponentWithId:component.componentID andManagedObjectContext:self.managedObjectContext];
                }
            }
            
            
        }
    
    }
    
    
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

//id of project
- (NSString *)getProjectID
{
    return self.project.projectID;
}

- (NSString *)getProjectName
{
    return self.project.name;
}



//checks weather the rating of the project is complete or not
//updates components' ratingCompleteProperty
- (BOOL)ratingIsComplete
{
    BOOL output = YES;
    Project *project = self.project;
    NSEnumerator *componentEnumerator = [project.consistsOf objectEnumerator];
    
    //iterate through components
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        BOOL componentComplete = YES;
        
        //iterate through all supercharacteristics
        SuperCharacteristic *superCharacteristic;
        NSEnumerator *superCharacteristicEnumerator = [comp.ratedBy objectEnumerator];
        
        while ((superCharacteristic = [superCharacteristicEnumerator nextObject]) != nil) {
            
            //iterate through all characteristics and check if one of them hasn't been rated yet (value == 0)
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superCharacteristic.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                if ([characteristic.value intValue] == 0) {
                    output = NO;
                    componentComplete = NO;
                    break;
                }
            }
        }
        
        
        if (componentComplete) {
            [comp setRatingComplete:[NSNumber numberWithBool:YES]];
        }
        
        
    }
    
    return output;
    
}





@end
