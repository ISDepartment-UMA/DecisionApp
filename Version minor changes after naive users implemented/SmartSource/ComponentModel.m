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

@interface ComponentModel()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Component *currentComponent;




@end

@implementation ComponentModel
@synthesize currentComponent = _currentComponent;
@synthesize managedObjectContext = _managedObjectContext;


//constructor that initializes the projectmodel and prepares the core database for the rating
- (ComponentModel *)initWithComponent:(Component *)component
{
    self = [super init];
    
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.currentComponent = component;
    return self;
}

- (Component *)getComponentObject
{
    return self.currentComponent;
}


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

- (void)saveWeight:(NSNumber *)weight forSuperCharacteristic:(NSString *)superChar
{
    //talk to core data to save project
    Project *rightProject = self.currentComponent.partOf;
    [SuperCharacteristic saveWeight:weight forSuperCharacteristic:superChar inProject:rightProject andManagedObjectContext:self.managedObjectContext];
    
}





@end
