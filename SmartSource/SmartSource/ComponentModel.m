//
//  ComponentModel.m
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import "ComponentModel.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Project+Factory.h"
#import "RadioButton.h"
#import "SmartSourceAppDelegate.h"
#import "WebServiceConnector.h"
#import "SmartSourceFunctions.h"

@interface ComponentModel()
@property (nonatomic, strong) Component *currentComponent;
@end

@implementation ComponentModel
@synthesize currentComponent = _currentComponent;


//constructor that initializes the componentmodel and prepares the core database for the rating
- (ComponentModel *)initWithComponentId:(NSString *)componentId
{
    self = [super init];
    self.currentComponent = [Component getComponentForId:componentId fromManagedObjectContext:self.managedObjectContext];
    return self;
}

//returns component object as in core database
- (Component *)getComponentObject
{
    return self.currentComponent;
}


//dictionary with supercharacteristics and their average values
- (NSDictionary *)getDictionaryWithSuperCharValues
{
    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:[self.currentComponent.ratedBy count]];
    for (SuperCharacteristic *superCharacteristic in self.currentComponent.ratedBy) {
        float sum = 0;
        for (Characteristic *characteristic in superCharacteristic.superCharacteristicOf) {
            sum+= [characteristic.value floatValue];
        }
        sum = sum/[superCharacteristic.superCharacteristicOf count];
        [output setObject:[NSNumber numberWithFloat:sum] forKey:superCharacteristic.name];
    }
    return [output copy];
}

- (BOOL)sodaValuesAreAvailable
{
    return (self.currentComponent.cohesion != nil);
}

//returns the characteristics and supercharacteristics of a component sorted by name
// 0 - superchars
// 1 - chars
// [n, m] - mth char for the nth superchar
- (NSArray *)getCharacteristics
{
    NSMutableArray *superChars = [NSMutableArray array];
    NSMutableArray *subChars = [NSMutableArray array];
    
    
    //sort supercharacteristics by name
    NSArray *superCharacteristicsSorted = [self.currentComponent.ratedBy sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    //iterate supercharacteristics of component
    for (SuperCharacteristic *superChar in superCharacteristicsSorted)
    {
        //add supercharacteristic to array
        [superChars addObject:superChar];
        //add all subcharacteristics to array
        NSMutableArray *subCharsTemp = [NSMutableArray array];
        for (Characteristic *charact in superChar.superCharacteristicOf) {
            [subCharsTemp addObject:charact];
        }
    
        //sort subcharacteristics by name
        NSArray *subCharsTempSorted = [NSArray arrayWithArray:subCharsTemp];
        subCharsTempSorted = [subCharsTempSorted sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        subCharsTemp = [NSMutableArray arrayWithArray:subCharsTempSorted];
        
        
        /*
         *  in communication complexity, put coupling and cohesion characteristics to top
         */
        BOOL alreadyMovedCohesion = NO;
        if ([superChar.name isEqualToString:@"Communication Complexity"]) {
            for (int i=0; i<[subCharsTemp count]; i++) {
                Characteristic *oneCharacteristic = [subCharsTemp objectAtIndex:i];
                if ([oneCharacteristic.name isEqualToString:@"Autonomy of requirements within this component"]) {
                    //shift all characteristics one spot down
                    for (int y=i; y>0; y--) {
                        [subCharsTemp replaceObjectAtIndex:y withObject:[subCharsTemp objectAtIndex:(y-1)]];
                    }
                    //put cohesion into first spot
                    [subCharsTemp replaceObjectAtIndex:0 withObject:oneCharacteristic];
                    alreadyMovedCohesion = YES;
                } else if (([oneCharacteristic.name isEqualToString:@"Number of inter-component requirements links"]) && alreadyMovedCohesion) {
                    //characteristics with index 1-i down one spot
                    for (int y=i; y>1; y--) {
                        [subCharsTemp replaceObjectAtIndex:y withObject:[subCharsTemp objectAtIndex:(y-1)]];
                    }
                    //put cohesion into first spot
                    [subCharsTemp replaceObjectAtIndex:1 withObject:oneCharacteristic];
                    break;
                //cohesion not moved yet
                } else  if ([oneCharacteristic.name isEqualToString:@"Number of inter-component requirements links"]) {
                    //characteristics with index 1-i down one spot
                    for (int y=i; y>0; y--) {
                        [subCharsTemp replaceObjectAtIndex:y withObject:[subCharsTemp objectAtIndex:(y-1)]];
                    }
                    //put cohesion into first spot
                    [subCharsTemp replaceObjectAtIndex:0 withObject:oneCharacteristic];
                }
            }
        }
        subCharsTempSorted = [subCharsTemp copy];
        //add subcharacteristics
        [subChars addObject:[NSArray arrayWithArray:subCharsTempSorted]];
    }
    return [NSArray arrayWithArray:[NSMutableArray arrayWithObjects:[NSArray arrayWithArray:superChars], [NSArray arrayWithArray:subChars], nil]];
}


//returns array with info about a component
- (NSArray *)getComponentInfo
{
    NSArray *componentInfo = [NSArray arrayWithObjects:@"ComponentInfo", self.currentComponent.componentID, self.currentComponent.name, self.currentComponent.descr, @"", @"", @"", nil];
    return componentInfo;
}


- (NSDictionary *)getComponentForID:(NSString *)componentID
{
    return [WebServiceConnector getComponentForID:componentID];
}

- (BOOL)saveContext
{
    return [Component saveContext:self.managedObjectContext];
}


//checks weather the rating of the project is complete or not
//updates components' ratingCompleteProperty
- (BOOL)ratingIsComplete
{
    BOOL output = YES;
    Project *project = self.currentComponent.partOf;
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


#pragma mark Results

/*returns used characteristics and rating values of a component in a three-dimensional array
 
 first dimension:
 0 --> superchars with values
 1 --> chars with values
 
 second dimension:
 0 --> char
 1 --> value/weight
 for supercharacteristics:
 3 --> relative weight as string - e.g. "75%"
 */
- (NSArray *)getCharsAndValuesArray
{   
    //initiate arrays of used supercharacteristics and characteristics
    NSMutableArray *usedSuperChars = [NSMutableArray array];
    NSMutableArray *usedChars = [NSMutableArray array];
    //initiate arrays for values
    NSMutableArray *valueSuperChars = [NSMutableArray array];
    NSMutableArray *valueChars = [NSMutableArray array];
    //relative weight of supercharacteristics
    NSMutableArray *relativeWeights = [NSMutableArray array];
    
    
    //iterate through all supercharacteristics
    SuperCharacteristic *superChar;
    
    //sort supercharacteristics
    NSArray *descriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSEnumerator *superCharEnumerator = [[self.currentComponent.ratedBy sortedArrayUsingDescriptors:descriptors] objectEnumerator];
    //total weight of supercharacteristics
    CGFloat totalWeightOfSuperCharacteristics = 0.0;
    for (SuperCharacteristic *superchar in self.currentComponent.ratedBy) {
        totalWeightOfSuperCharacteristics += [superchar.weight floatValue];
    }
    //iterate
    while ((superChar = [superCharEnumerator nextObject]) != nil) {
        
        //add supercharacteristic to used supercharacteristic array
        [usedSuperChars addObject:superChar.name];
        //relative weight
        float weight = ([superChar.weight floatValue]/totalWeightOfSuperCharacteristics);
        [relativeWeights addObject:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
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
    
    NSArray *output = [NSArray arrayWithObjects:[NSArray arrayWithObjects:[usedSuperChars copy], [valueSuperChars copy], [relativeWeights copy], nil], [NSArray arrayWithObjects:[usedChars copy], [valueChars copy], nil], nil];
    
    return output;
}

/*
 
 Returns Dictionary with characteristics, subcharacteristics used
    explanation text, values for rows of explanation view
 
 */
- (NSDictionary *)calculateDetailedResults
{
    //init output
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //get chars and values
    NSArray *returnedValues = [self getCharsAndValuesArray];
    NSArray *superChars = [returnedValues objectAtIndex:0];
    NSArray *chars = [returnedValues objectAtIndex:1];
    //output
    [dictionary setObject:superChars forKey:@"superChars"];
    [dictionary setObject:chars forKey:@"chars"];
    //string for result explanation
    NSString *explanationTmp = @"Since you rated";
    //init weighted sum of supercharacteristics
    CGFloat weightedSumOfSupercharacteristics = 0.0;
    CGFloat totalWeightOfSuperCharacteristics = [self getTotalWeightOfSuperCharacteristics];
    //init output
    NSMutableArray *mutableValuesForCells = [NSMutableArray array];
    
    //for every supercharacteristic
    for (int i=0; i<[[superChars objectAtIndex:0] count]; i++) {
        
        NSMutableArray *valuesForCell = [NSMutableArray array];
        
        //add name of characteristic...
        NSString *nameOfSuperCharacteristic = [[superChars objectAtIndex:0] objectAtIndex:i];
        
        //...to cells
        [valuesForCell addObject:nameOfSuperCharacteristic];
        
        // ...to explanation
        if ((i == ([[superChars objectAtIndex:0] count]-1)) && (i > 0)) {
            explanationTmp = [[explanationTmp stringByAppendingString:@" and "] stringByAppendingString:nameOfSuperCharacteristic];
        } else if (i > 0){
            explanationTmp = [[explanationTmp stringByAppendingString:@", "] stringByAppendingString:nameOfSuperCharacteristic];
        } else {
            explanationTmp = [[explanationTmp stringByAppendingString:@" "] stringByAppendingString:nameOfSuperCharacteristic];
        }
        
        
        //add evaluation
        NSArray *subCharacteristicsValues = [[chars objectAtIndex:1] objectAtIndex:i];
        float sum = 0.0;
        //add all values
        for (int y=0; y<[subCharacteristicsValues count]; y++) {
            sum = sum + [[subCharacteristicsValues objectAtIndex:y] floatValue];
        }
        //devide the sum by the number of characteristics --> average and extract the rating of the supercharacteristic
        float superCharValue = sum/[subCharacteristicsValues count];
        
        //add rating average string name
        // ... to cell
        [valuesForCell addObject:[SmartSourceFunctions getHighMediumLowStringForFloatValue:superCharValue]];
        //...to explanation
        explanationTmp = [[explanationTmp stringByAppendingString:@" "] stringByAppendingString:[SmartSourceFunctions getSmallHighMediumLowStringForFloatValue:superCharValue]];
        
        //add rating average string number
        [valuesForCell addObject:[NSString stringWithFormat:@"%.1f", superCharValue]];
        
        //add weight
        float weight = ([[[superChars objectAtIndex:1] objectAtIndex:i] floatValue]/totalWeightOfSuperCharacteristics);
        [valuesForCell addObject:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
        
        //add weighted average
        float weightedAverage = ([[[superChars objectAtIndex:1] objectAtIndex:i] floatValue]/totalWeightOfSuperCharacteristics) * superCharValue;
        [valuesForCell addObject:[NSString stringWithFormat:@"%.1f", weightedAverage]];
        
        //add the weighted value to the end rating value
        weightedSumOfSupercharacteristics += ([[[superChars objectAtIndex:1] objectAtIndex:i] floatValue]/totalWeightOfSuperCharacteristics) * superCharValue;
        
        //add array to mutableValuesForCells
        NSArray *result = [valuesForCell copy];
        [mutableValuesForCells addObject:result];
    }
    
    //output 1
    NSArray *valuesForCells = [mutableValuesForCells copy];
    
    //check if sum of weighted averages is correct
    CGFloat sum = 0.0;
    for (NSArray *oneCellsValues in valuesForCells) {
        sum += [[oneCellsValues lastObject] floatValue];
    }
    
    //if sum is not the same then add difference to last superchars weighted average
    CGFloat roundedWeightedSumOfSupercharacteristics = [[NSString stringWithFormat:@"%.1f", weightedSumOfSupercharacteristics] floatValue];
    CGFloat roundedSumFromLabels = [[NSString stringWithFormat:@"%.1f", sum] floatValue];
    
    if (roundedSumFromLabels != roundedWeightedSumOfSupercharacteristics) {
        
        CGFloat difference = roundedSumFromLabels - roundedWeightedSumOfSupercharacteristics;
        if (difference < 0) {
            difference = difference * (-1);
        }
        
        NSMutableArray *lastCellsValues = [[valuesForCells lastObject] mutableCopy];
        CGFloat newWeightedAverage = [[[valuesForCells lastObject] lastObject] floatValue] + difference;
        [lastCellsValues replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"%.1f", newWeightedAverage]];
        [mutableValuesForCells replaceObjectAtIndex:([valuesForCells count]-1) withObject:[lastCellsValues copy]];
        valuesForCells = [mutableValuesForCells copy];
    }
    //add to output
    [dictionary setObject:valuesForCells forKey:@"valuesForCells"];
    [dictionary setObject:[NSNumber numberWithFloat:weightedSumOfSupercharacteristics] forKey:@"weightedSumOfSupercharacteristics"];
    
    explanationTmp = [[[explanationTmp stringByAppendingString:@", the weighted average is "] stringByAppendingString:[SmartSourceFunctions getSmallHighMediumLowStringForFloatValue:weightedSumOfSupercharacteristics]] stringByAppendingString:@" which indicates"];
    
    if (weightedSumOfSupercharacteristics < 1.67) {
        explanationTmp = [explanationTmp stringByAppendingString:@" outsourcing."];
    } else if (weightedSumOfSupercharacteristics < 2.34) {
        explanationTmp = [explanationTmp stringByAppendingString:@" indifference."];
    } else if (weightedSumOfSupercharacteristics <= 3.0) {
        explanationTmp = [explanationTmp stringByAppendingString:@" a core component that should be produced in-house."];
    }
    
    [dictionary setObject:explanationTmp forKey:@"explanationText"];
    return [dictionary copy];
    
}

- (CGFloat)getTotalWeightOfSuperCharacteristics
{
    //calculate the sum of all weights of supercharacteristics
    float totalWeightOfSupercharacteristics = 0.0;
    for (SuperCharacteristic *superChar in self.currentComponent.ratedBy) {
        totalWeightOfSupercharacteristics += [superChar.weight floatValue];
    }
    return totalWeightOfSupercharacteristics;
}





@end
