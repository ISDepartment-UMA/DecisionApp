//
//  ComponentsTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 19.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ComponentsTableViewController.h"
#import "SBJson.h"
#import "RatingTableViewViewController.h"
#import "DetailTableViewController.h"
#import "Characteristic+Factory.h"
#import "ResultMasterViewController.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Project+Factory.h"
#import "Component+Factory.h"

@interface ComponentsTableViewController ()

@property (strong, nonatomic) IBOutlet UIButton *showResultsButton;
@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *characteristics;
@property (strong, nonatomic) NSString *currentProject;



@end



@implementation ComponentsTableViewController
//synthesize
@synthesize ratingScreen = _ratingScreen;
@synthesize showResultsButton = _showResultsButton;
@synthesize availableCells = _availableCells;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentProject = _currentProject;
@synthesize characteristics = _characteristics;




//prepares the core database for the rating of the project and returns a 2 dimensional array
//1st dimension: - 0 for supercharacteristics names - 1 for subcharacteristics names of supercharacteristic at value of 0
- (NSArray *)prepareDatabaseForProjectRating:(NSString *)projectID
{
    //getting characteristics from core database
    //get all supercharacteristics
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
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
            for (int y=0; y<[self.availableCells count]; y++) {
                NSString *componentID = [[self.availableCells objectAtIndex:y] objectAtIndex:0];
                [Characteristic addNewCharacteristic:tmpcharacteristic.name withValue:[NSNumber numberWithInt:0] toSuperCharacteristic:tmpasc.name withWeight:[NSNumber numberWithInt:3] andComponent:componentID andProject:projectID andManagedObjectContext:self.managedObjectContext];
            }
            
            
        }
        
        //add array of subcharacteristics to the array of subcharacteristics
        [subchar addObject:tmp];
    }
    
    NSArray *output = [NSArray arrayWithObjects:superchar, subchar, nil];
    return output;
}


//checks weather the rating of the currently displayed project is complete or not
- (BOOL)ratingIsComplete
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", self.currentProject];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    Project *project = [matches lastObject];
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




//method to set the project, the components should be retrieved from
- (void)setProject:(NSString *)projectID
{
    
    self.availableCells = [self getAllComponentsForProjectId:projectID];
    self.currentProject = projectID;
    self.characteristics = [self prepareDatabaseForProjectRating:projectID];
    [self.tableView reloadData];

}


//segues to ResultMAsterViewController to show results of project rating
- (IBAction)showResultsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showResults" sender:self];
}

- (void)checkForCompleteness
{
    if ([self ratingIsComplete]) {
        self.showResultsButton.hidden = NO;
    }
}


//import all components of a project from the webservice
- (NSArray *)getAllComponentsForProjectId:(NSString *)projectID
{
    
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceURL = @"";
    NSString *login = @"";
    NSString *password = @"";
    
    if (loginData != nil) {
        
        //decode url to pass it in http request
        serviceURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    }
    
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    //building the url
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getAllComponentsForProject?url=" stringByAppendingString:serviceURL] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *components = [responsedic objectForKey:@"return"];
    
    //if the project has just one component, return it
    if ([components isKindOfClass:[NSDictionary class]]) {
        NSString *id = [NSString stringWithFormat:@"%d", [[components objectForKey:@"id"] integerValue]];
        NSString *name = [components objectForKey:@"name"];
        NSString *descr = [components objectForKey:@"description"];
        return [NSArray arrayWithObject:[NSArray arrayWithObjects:id, name, descr, nil]];
        
    //else it consists of more than one component --> NSDictionaries inside an NSArray
    } else {
        NSEnumerator *enumerator = [components objectEnumerator];
        NSMutableArray *output = [NSMutableArray arrayWithCapacity:1];
        
        NSDictionary *temp;
        while ((temp = [enumerator nextObject]) != nil) {
            NSString *id = [NSString stringWithFormat:@"%d", [[temp objectForKey:@"id"] integerValue]];
            NSString *name = [temp objectForKey:@"name"];
            NSString *description = [temp objectForKey:@"description"];
            [output addObject:[NSArray arrayWithObjects:id, name, description, nil]];
        }
        return output;
    }
    
    
    
}


- (void)awakeFromNib  // always try to be the split view's delegate
{
    [super awakeFromNib];
    [self.tableView reloadData];
}


//init with sytle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidUnload
{

    [self setShowResultsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //add observer for notifications
    //this notification makes the ComponentTableViewController select
    //  a) the first component if an empty nsdictionary is passed as user info
    //  b) a certain component if its copmponentID is passed in a dictionary via user info --> objectforKey:@"id"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectComponent:) name:@"ComponentTableViewControllerSelect" object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //pop detail view back to rating view controller
    [self.ratingScreen.navigationController popToViewController:self.ratingScreen animated:NO];
    
    //if detail view is now not a RatingTableViewController, then return to root view controller and perform segue
    //ths is necessary when poping back from the componentdetailinfoviewcontroller and the rating table view controller hasn't been pushed so far
    UINavigationController *navigation = [self.splitViewController.viewControllers lastObject];
    if (![navigation.visibleViewController isKindOfClass:[RatingTableViewViewController class]]) {
        [navigation popToRootViewControllerAnimated:NO];
        [[navigation.viewControllers objectAtIndex:0] performSegueWithIdentifier:@"ratingScreen" sender:self];
    }

    
    //select first row
    if ([self.availableCells count] > 0) {
        
        [self.ratingScreen setComponent:[[self.availableCells objectAtIndex:0] objectAtIndex:0] ofProject:self.currentProject withRatingCharacteristics:self.characteristics];
    }
    

}

- (void)selectComponent:(NSNotification *)notification
{
    NSString *projectID = [notification.userInfo objectForKey:@"id"];
    
    if (projectID != nil) {
        for (int i=0; i<[self.availableCells count]; i++) {
            if ([[[self.availableCells objectAtIndex:i] objectAtIndex:0] isEqualToString:projectID])
            {
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
        }
    } else if ([self.availableCells count] > 0){
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
    
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Projects", @"Projects");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.availableCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"componentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //configure cell for component
    
    NSArray *componentInfo = [self.availableCells objectAtIndex:indexPath.row];
    
    // Configure the cell...
    if ([[self.availableCells objectAtIndex:indexPath.row] count]>0) {
        cell.textLabel.text = [componentInfo objectAtIndex:1];
    } else {
        cell.textLabel.text =@"";
    }
    
    return cell;
}










#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //set the currently displayed component in the rating table view controller
    NSString *componentID = [[self.availableCells objectAtIndex:indexPath.row] objectAtIndex:0];
    [self.ratingScreen setComponent:componentID ofProject:self.currentProject withRatingCharacteristics:self.characteristics];


}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //show results
    if ([segue.identifier isEqualToString:@"showResults"]) {
        ResultMasterViewController *resultMVC = segue.destinationViewController;
        resultMVC.managedObjectContext = self.managedObjectContext;
        [resultMVC prepareResultsForProject:self.currentProject];
        
        //push at a glance to detail view
        [self.ratingScreen performSegueWithIdentifier:@"atAGlance" sender:resultMVC];
    }
}

@end
