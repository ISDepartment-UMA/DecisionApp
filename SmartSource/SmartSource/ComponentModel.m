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

- (IBAction)checkboxButton:(RadioButton *)button
{
    //check for other buttons in the same cell and uncheck them
    for (UIButton *otherButton in [button.superview subviews]) {
        if ([otherButton isKindOfClass:[button class]] && ![otherButton isEqual:button]) {
            [otherButton setSelected:NO];
        }
    }
    
    //check the touched button
    if (!button.selected) {
        button.selected = !button.selected;
        
        //get the cell of the button
        UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
        
        //store selection in the core database
        Characteristic *charact = [button getCurrentCharacteristic];
        charact.value = [NSNumber numberWithInt:button.tag];
        
        //save context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        //check for rating completeness
        //[self.currentModel checkForCompleteness];
    }
    
    
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
    //store value
    Project *rightProject = self.currentComponent.partOf;
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
     NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", superChar];
     NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", rightProject.projectID];
     NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
     request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
     
     NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
     request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
     NSError *error = nil;
     NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
     
     //set weight of this supercharacteristic for ALL COMPONENTS of the current project
     for (SuperCharacteristic *rightSuperCharacteristic in matches) {
         rightSuperCharacteristic.weight = weight;
     }
     
     
     if (![self.managedObjectContext save:&error]) {
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alert show];
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
    
}

@end
