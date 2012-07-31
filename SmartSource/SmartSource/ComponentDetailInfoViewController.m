//
//  ComponentDetailInfoViewController.m
//  SmartSource
//
//  Created by Lorenz on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ComponentDetailInfoViewController.h"
#import "SBJson.h"
#import "Component+Factory.h"
#import "SuperCharacteristic.h"
#import "Characteristic.h"
#import "ComponentsTableViewController.h"
#import "ClassificationExplanationViewController.h"


@interface ComponentDetailInfoViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *currentComponent;
@property (strong, nonatomic) NSArray *informationTitles;

@property (strong, nonatomic) NSArray *superChars;
@property (strong, nonatomic) NSArray *chars;

@end

@implementation ComponentDetailInfoViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentComponent = _currentComponent;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize informationTitles = _informationTitles;
@synthesize superChars = _superChars;
@synthesize chars = _chars;








- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = [self.currentComponent objectAtIndex:1];
    
    //put button to change rating into navigation bar
    UIBarButtonItem *rateProject = [[UIBarButtonItem alloc] initWithTitle:@"Back to Rating Screen" style:UIBarButtonItemStyleBordered target:self action:@selector(rateProjectPressed)];
    UIBarButtonItem *showExplanation = [[UIBarButtonItem alloc] initWithTitle:@"Show Explanation" style:UIBarButtonItemStyleBordered target:self action:@selector(explanationPressed)];
    NSArray *buttons = [NSArray arrayWithObjects:showExplanation, rateProject, nil];
    [self.navigationItem setRightBarButtonItems:buttons];

}


- (void)explanationPressed
{
    [self performSegueWithIdentifier:@"showExplanation" sender:self];
}
//method executed when user wants to rerate the project
- (void)rateProjectPressed
{
    //pop to SmartSourceMasterViewcontroller
    UINavigationController *navigation = [self.splitViewController.viewControllers objectAtIndex:0];    
    [navigation popToRootViewControllerAnimated:NO];
    
    //perform segue to componentsTableViewController
    [[navigation.viewControllers objectAtIndex:0] performSegueWithIdentifier:@"componentsMenu" sender:self];
    
    //post notification to select the right component
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self.currentComponent objectAtIndex:0] forKey:@"id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ComponentTableViewControllerSelect" object:nil userInfo:userInfo];
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//public method to set displayed component from other view controllers
- (void)setComponent:(NSString *)componentID;
{
    //setting the componentInfo
    NSDictionary *component = [self getComponentForID:componentID];
    NSString *estimatedHours = [NSString stringWithFormat:@"%d", [[component objectForKey:@"estimatedhours"] integerValue]];
    self.currentComponent = [NSArray arrayWithObjects:componentID, [component objectForKey:@"name"], [component objectForKey:@"description"], [component objectForKey:@"priority"], estimatedHours, [component objectForKey:@"modifier"], nil];
    self.informationTitles = [NSArray arrayWithObjects:@"Component ID", @"Name", @"Description", @"Priority", @"Estimated Hours", @"Modifier", nil];
    
    
    //retrieving the rating values
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Component"];
    request.predicate = [NSPredicate predicateWithFormat:@"id =%@", componentID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    Component *comp = [matches lastObject];

    
    
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
            if ([characteristic.value isEqualToNumber:[NSNumber numberWithInt:1]]) {
                [valueOfCharacteristics addObject:@"low"];
            } else if ([characteristic.value isEqualToNumber:[NSNumber numberWithInt:2]]) {
                [valueOfCharacteristics addObject:@"medium"];
            } else if ([characteristic.value isEqualToNumber:[NSNumber numberWithInt:3]]) {
                [valueOfCharacteristics addObject:@"high"];
            } else {
                [valueOfCharacteristics addObject:@"none"];
            }
            
            
            
        }
        
        //add array of characteristics to characteristics array
        [usedChars addObject:characteristicsOfSuperchar];
        [valueChars addObject:valueOfCharacteristics];
        
        
    }
    
    

    self.superChars = [NSArray arrayWithObjects:[usedSuperChars copy], [valueSuperChars copy], nil];
    self.chars = [NSArray arrayWithObjects:[usedChars copy], [valueChars copy], nil];
    
    [self.tableView reloadData];
}

//returns an nsdictionary with component info for a given component id
- (NSDictionary *)getComponentForID:(NSString *)componentID
{
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    
    if (loginData != nil) {
        
        //decode url to pass it in http request
        serviceUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getComponentInfo?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Result Overview", @"Result Overview");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of used supercharacteristics +1
    NSArray *usedSuperChars = [self.superChars objectAtIndex:0];
    return [usedSuperChars count]+1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //in first section return number of component information
    if (section == 0) {
        return @"Component Info";
        
    //in all the other sections, return number of subcharacteristics of the certain supercharacteristic
    } else {
        
        NSArray *usedSuperChars = [self.superChars objectAtIndex:0];
        return [usedSuperChars objectAtIndex:(section-1)];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        //return number of info about the component
        return [self.currentComponent count];
        
    } else {
        
        //return number of characteristics of supercharacteristics + 1
        NSArray *usedCharacteristics = [self.chars objectAtIndex:0];
        return [[usedCharacteristics objectAtIndex:(section-1)] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"infoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        //add information title to text label

        
        //add information title
        cell.textLabel.text = [self.informationTitles objectAtIndex:indexPath.row];

        //add information of current component to the detail text label of the cell
        cell.detailTextLabel.text = [self.currentComponent objectAtIndex:indexPath.row];
    } else {
        
        //set text label to characteristic's name
        NSArray *usedCharacteristics = [self.chars objectAtIndex:0];
        cell.textLabel.text = [[usedCharacteristics objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row];
        
        //set detail text label to characteristic's value
        NSArray *valueOfCharacteristics = [self.chars objectAtIndex:1];
        
        
        cell.detailTextLabel.text = [[valueOfCharacteristics objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row] 
        ;
        
        
        
    }

    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showExplanation"]) {
        ClassificationExplanationViewController *dest = segue.destinationViewController;
        dest.managedObjectContext = self.managedObjectContext;
        [dest setComponent:[self.currentComponent objectAtIndex:0]];
    }
}

@end
