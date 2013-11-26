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
#import "PDFExporter.h"
#import "Requirement+Factory.h"
#import "Graph.h"
#import "GraphEdge.h"
#import "GraphNode.h"
#import "SODAFunctions.h"
#import "Component+Factory.h"

@interface ProjectModel ()
@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *classificationResult;


//for results
@property (nonatomic) float totalWeightOfSuperCharacteristics;

//for decision table
@property (strong, nonatomic) NSDictionary *superCharValueDic;

//SODA


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


//returns supercharacteristics used in first component of the proeject
- (NSArray *)getSuperCharacteristics
{
    Component *firstComponent = (Component *)[[self.project.consistsOf objectEnumerator] nextObject];
    //sort supercharacteristics by name
    NSArray *superCharacteristicsSorted = [firstComponent.ratedBy sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    return superCharacteristicsSorted;
}


- (void)saveWeightValue:(CGFloat)value forSuperCharacteristicWithName:(NSString *)superCharacteristicName
{
    [SuperCharacteristic saveWeight:[NSNumber numberWithFloat:value] forSuperCharacteristic:superCharacteristicName inProject:self.project andManagedObjectContext:self.managedObjectContext];
}


//method that calculates the results of the evaluation
- (NSArray *)calculateResults
{
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



- (BOOL)ratingCharacteristicsHaveBeenAdded
{
    //available characteristics from settings
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
                        //ignore cohesion and coupling
                        if (!([usedCharacteristic.name isEqualToString:@"Coupling"] || [usedCharacteristic.name isEqualToString:@"Cohesion"])) {
                            return true;
                        }
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


#pragma mark SODA

- (ProjectModel *)initWithProjectID:(NSString *)idOfProject useSoda:(BOOL)useSoda
{
    //build project model
    self = [[ProjectModel alloc] initWithProjectID:idOfProject];
    
    if (useSoda && (![self sodaValuesAvailable])) {
        
        //download requirements...
        [self downloadAllRequirementsForProject];
        //...and build graph
        Graph *requirementsGraph = [self buildGraphFromRequirements];
        
        //build dictionary with clusternames = componentnames and sets of requirementnodes
        NSMutableDictionary *clusterDictionaryMutable = [NSMutableDictionary dictionary];
        
        //build array of NSSets with requirements - one NSSet for each component, representing the clusters
        for (Component *oneComponent in self.project.consistsOf) {
            
            //build NSSet with nodes of graph
            NSMutableSet *nodeSetMutable = [NSMutableSet set];
            for (Requirement *requirementInSubset in oneComponent.relatedRequirements) {
                [nodeSetMutable addObject:[requirementsGraph nodeWithValue:requirementInSubset]];
            }
            NSSet *nodeSet = [nodeSetMutable copy];
            //use set of nodes to get cohesion of cluster
            oneComponent.cohesion = [NSNumber numberWithFloat:[SODAFunctions getCohesionOfClusterWithRequirementsSubset:nodeSet inRequirementsGraph:requirementsGraph]];
            //add NSSet of nodes to dictionary of clusters
            [clusterDictionaryMutable setObject:nodeSet forKey:oneComponent.componentID];
        }
        
        //imutable Array and results of relative coupling
        NSDictionary *clusterDictionary = [NSDictionary dictionaryWithDictionary:clusterDictionaryMutable];
        NSDictionary *dictionaryOfCouplingValuesForCcomponents = [SODAFunctions getCouplingValuesForClusteringDictionary:clusterDictionary inRequirementsGraph:requirementsGraph];
        
        //get highmediumlow value of coupling and cohesion for every component and save it into database
        for (Component *oneComponent in self.project.consistsOf) {
            oneComponent.coupling = [dictionaryOfCouplingValuesForCcomponents objectForKey:oneComponent.componentID];

            NSNumber *valueCohesion = [SODAFunctions get123ValueForLinearValue:(1-[oneComponent.cohesion floatValue])];
            NSNumber *valueCoupling = [SODAFunctions get123ValueForLinearValue:[oneComponent.coupling floatValue]];
            //add characteristicsort
            BOOL found = NO;
            for (SuperCharacteristic *superChar in oneComponent.ratedBy) {
                if ([superChar.name isEqualToString:@"Communication Complexity"]) {
                    for (Characteristic *oneCharacteristic in superChar.superCharacteristicOf) {
                        if ([oneCharacteristic.name isEqualToString:@"Cohesion"]) {
                            //set values
                            [oneCharacteristic setValue:valueCohesion];
                            found = YES;
                        } else if ([oneCharacteristic.name isEqualToString:@"Coupling"]) {
                            [oneCharacteristic setValue:valueCoupling];
                            found = YES;
                        }
                    }
                }
            }
            if (!found) {
                //insert characteristics for values
                [Characteristic addNewCharacteristic:@"Cohesion" withValue:valueCohesion toSuperCharacteristic:@"Communication Complexity" withWeight:[NSNumber numberWithInt:3] andComponent:oneComponent.componentID andProject:oneComponent.partOf.projectID andManagedObjectContext:self.managedObjectContext];
                [Characteristic addNewCharacteristic:@"Coupling" withValue:valueCoupling toSuperCharacteristic:@"Communication Complexity" withWeight:[NSNumber numberWithInt:3] andComponent:oneComponent.componentID andProject:oneComponent.partOf.projectID andManagedObjectContext:self.managedObjectContext];
            }
            
            [Component saveContext:self.managedObjectContext];
        }
    }
    return self;
}

- (BOOL)sodaValuesAvailable
{
    Component *arbritaryComponent = [[self.project.consistsOf objectEnumerator] nextObject];
    if (arbritaryComponent.cohesion) {
        return YES;
    } else {
        return NO;
    }
}

- (void)downloadAllRequirementsForProject
{
    NSArray *requirements = [WebServiceConnector getRequirementsAndInterdependenciesForProject:self.project.projectID];
    for (NSDictionary *oneRequirement in requirements) {
        [Requirement addNewRequirementWithId:[oneRequirement objectForKey:@"id"] andName:[oneRequirement objectForKey:@"name"] andLinkedRequirements:[oneRequirement objectForKey:@"connectedRequirements"] andLinkedComponents:[oneRequirement objectForKey:@"connectedComponents"] andProjectId:self.project.projectID toManagedObjectContext:self.managedObjectContext];
    }
    
}

- (Graph *)buildGraphFromRequirements
{
    Graph *requirementsGraph = [[Graph alloc] init];
    //iterate requirements
    for (Requirement *oneRequirement in self.project.hasRequirements) {
        //add node
        GraphNode *oneReqNode = [requirementsGraph nodeWithValue:oneRequirement];
        
        for (Requirement *linkedRequirement in oneRequirement.linkedWith) {
            //add edge
            [requirementsGraph addEdgeFromNode:oneReqNode toNode:[requirementsGraph nodeWithValue:linkedRequirement] withWeight:1.0];
        }
    }
    
    return requirementsGraph;
}


//temp
- (void)printAllRequirements
{
    NSLog(@"------ printAllRequirements --------");
    for (Component *oneComponent in self.project.consistsOf) {
        NSLog(oneComponent.name);
        for (Requirement *linkedReq in oneComponent.relatedRequirements) {
            NSLog([NSString stringWithFormat:@" - %@", linkedReq.name]);
        }
    }
    NSLog(@"-------------------------------------");
}

#pragma mark - Core Data Methods

- (BOOL)saveContext
{
    return [Project saveContext:self.managedObjectContext];
}


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
            //characteristics - supercharacteristics will be created automatically
            for (AvailableCharacteristic *charToAdd in charsToAdd) {
                //if database already contains 
                [Characteristic addNewCharacteristic:charToAdd.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:charToAdd.hasAvailableSuperCharacteristic.name withWeight:[NSNumber numberWithInt:3] andComponent:componentOfProject.componentID andProject:self.project.projectID andManagedObjectContext:self.managedObjectContext];
            }
        }
    }

    //characteristics do remove
    if ([self ratingCharacteristicsHaveBeenDeleted]) {
        //initialize sets to collect
        NSMutableSet *characteristicsToDelete = [NSMutableSet set];
        NSMutableSet *superCharacteristicsToDelete = [NSMutableSet set];
        //get available characteristics
        NSArray *availableSuperCharacteristics = [AvailableSuperCharacteristic getAllAvailableSuperCharacteristicsFromManagedObjectContext:self.managedObjectContext];
        //one component to check
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
                            [characteristicsToDelete addObject:usedChar.name];
                        }
                    }
                }
            }
            if (!foundSuperChar) {
                [superCharacteristicsToDelete addObject:usedSuperChar.name];
            }
        }
        //collection of chars to remove
        NSSet *charsToDelete = [characteristicsToDelete copy];
        NSSet *superCharsToDelete = [superCharacteristicsToDelete copy];
        //delete
        for (Component *componentOfProject in self.project.consistsOf) {
            //delete supercharacteristics
            for (NSString *superChar in superCharsToDelete) {
                [SuperCharacteristic deleteSuperCharacteristicWithName:superChar fromComponentWithId:componentOfProject.componentID andManagedObjectContext:self.managedObjectContext];
            }
            //delete characteristics
            for (NSString *charToDelete in charsToDelete) {
                [Characteristic deleteCharacteristicWithName:charToDelete fromComponentWithId:componentOfProject.componentID andManagedObjectContext:self.managedObjectContext];
            }
            //delete superchars that do not have any chars any more
            for (SuperCharacteristic *usedSC in component.ratedBy) {
                if ([usedSC.superCharacteristicOf count] < 1) {
                    [SuperCharacteristic deleteSuperCharacteristicWithName:usedSC.name fromComponentWithId:componentOfProject.componentID andManagedObjectContext:self.managedObjectContext];
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

//get and set project weighting edited
- (BOOL)getProjectHasBeenWeighted
{
    return [self.project.weightingHasBeenEdited boolValue];
}

- (void)setProjectHasBeenWeightedTrue
{
    [self.project setWeightingHasBeenEdited:[NSNumber numberWithBool:YES]];
    [Project saveContext:self.managedObjectContext];
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
        //mark component in core database as completely rated or not rated
        if (componentComplete) {
            [comp setRatingComplete:[NSNumber numberWithBool:YES]];
        } else {
            [comp setRatingComplete:[NSNumber numberWithBool:NO]];
        }
    }
    if ([project.consistsOf count] == 0) {
        output = NO;
    }
    return output;
}

#pragma mark ReportGeneration

- (NSString *)createReportPdfAndReturnPathPrinterFriendly:(BOOL)printerFriendly
{
    // create document
    PDFExporter *exporter = [[PDFExporter alloc] initWithProjectModel:self];
    NSString *fileName = [exporter generatePdfPrinterFriendly:printerFriendly];
    self.project.pathReportPdf = fileName;
    [self saveContext];
    return fileName;
}


- (BOOL)uploadPdfToCollaborationPlatformNewCreationNecessary:(BOOL)necessary
{
    //check if document already present
    if (necessary) {
        [self createReportPdfAndReturnPathPrinterFriendly:NO];
    }
     NSString *fileName = [[@"SmartSourcer Results - " stringByAppendingString:[self getProjectName]] stringByAppendingString:@".pdf"];
    return [WebServiceConnector uploadFileWithPath:self.project.pathReportPdf withName:fileName toProject:self.project.projectID];
}




@end
