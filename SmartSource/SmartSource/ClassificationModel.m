//
//  ClassificationModel.m
//  SmartSource
//
//  Created by Lorenz on 28.02.13.
//
//

#import "ClassificationModel.h"
#import "Project+Factory.h"
#import "Component+Factory.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "SmartSourceAppDelegate.h"
#import "SBJson.h"
#import "WebServiceConnector.h"

@interface ClassificationModel()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, strong) Project *currentProject;



@end

@implementation ClassificationModel
@synthesize currentProject = _currentProject;
@synthesize classification = _classification;
@synthesize managedObjectContext = _managedObjectContext;


//id of project
- (NSString *)getProjectID
{
    return self.currentProject.projectID;
}

- (NSString *)getProjectName
{
    return self.currentProject.name;
}


//array with id and name
- (NSArray *)getProjectArray
{
    return [NSArray arrayWithObjects:self.currentProject.projectID, self.currentProject.name, nil];
}

- (ClassificationModel *) initWithProjectID:(NSString *)projectID
{
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    //get project
    self.currentProject = [Project getProjectForId:projectID fromManagedObjectContext:self.managedObjectContext];
    NSEnumerator *componentEnumerator = [self.currentProject.consistsOf objectEnumerator];
    
    //iterate through components
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
            double valueOfSuperCharacteristic = 0.0;
            
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
            [[classification objectAtIndex:2] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        } else if (componentWeightedValue < 2.34) {
            [[classification objectAtIndex:1] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        } else if (componentWeightedValue <= 3.0) {
            [[classification objectAtIndex:0] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        }
    }
    
    self.classification = classification;
    return self;
}

/* returns components of A, B or C components of the current classification
 A -- @"A - Components"
 */
- (NSArray *)getComponentsForCategory:(NSString *)category
{
    if ([category isEqualToString:@"A - Components"]) {
        return [self.classification objectAtIndex:0];
    } else if ([category isEqualToString:@"B - Components"]){
        return [self.classification objectAtIndex:1];
    } else if ([category isEqualToString:@"C - Components"]){
        return [self.classification objectAtIndex:2];
    } else {
        return [NSArray array];
    }
    
}

//creates a table featuring all possible combinations of characteristics ratings and their result for the classification
- (NSArray *)getColumnsForDecisionTable
{
    Component *oneComponent = [self.currentProject.consistsOf objectEnumerator].nextObject;
    
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
            [tmpWeightedValues addObject:@"C"];
        } else if (weightedValue < 2.34) {
            [tmpWeightedValues addObject:@"B"];
        } else if (weightedValue <= 3) {
            [tmpWeightedValues addObject:@"A"];
        }
        
        
        
        
    }
    
    NSArray *weightedValues = [NSArray arrayWithObjects:@"Weighted Value", @"", tmpWeightedValues, nil];
    [columns addObject:weightedValues];
    
    return [columns copy];
    
    
    
}


//returns two-dimensional array with componentinfo
//0 --> keys
//1 --> objects
- (NSArray *)getComponentInfoForID:(NSString *)componentID
{
    
    NSDictionary *returnedObjects = [WebServiceConnector getComponentForID:componentID];
    
    //put info into two-dimensional array
    //get info about component
    NSMutableArray *mutableCurrentComponent = [NSMutableArray array];

    //put id to 0 and name to 1 and fill up with info about component
    NSMutableArray *mutableInformationTitles = [NSMutableArray arrayWithObjects:@"id", @"name", nil];
    for (NSString *title in [returnedObjects allKeys])
        if (![mutableInformationTitles containsObject:title]) {
            [mutableInformationTitles addObject:title];
        }
    NSArray *informationTitles = [NSArray arrayWithArray:mutableInformationTitles];
    
    for (NSString *key in informationTitles) {
        
        //replace ID with string, eles just add information
        if ([key isEqualToString:@"id"]) {
            [mutableCurrentComponent addObject:componentID];
        } else {
            [mutableCurrentComponent addObject:[returnedObjects objectForKey:key]];
        }
    }
    
    return [NSArray arrayWithObjects:informationTitles, [NSArray arrayWithArray:mutableCurrentComponent], nil];
    

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

@end
