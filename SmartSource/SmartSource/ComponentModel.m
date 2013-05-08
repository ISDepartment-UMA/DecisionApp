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
    NSArray *componentInfo = [NSArray arrayWithObjects:@"ComponentInfo", self.currentComponent.id, self.currentComponent.name, self.currentComponent.descr, @"", @"", @"", nil];
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
- (BOOL)ratingIsComplete
{
    
    Project *project = self.currentComponent.partOf;
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

- (void)saveWeight:(NSNumber *)weight forSuperCharacteristic:(NSString *)superChar
{
    //talk to core data to save project
    Project *rightProject = self.currentComponent.partOf;
    [SuperCharacteristic saveWeight:weight forSuperCharacteristic:superChar inProject:rightProject andManagedObjectContext:self.managedObjectContext];
    
}





@end
