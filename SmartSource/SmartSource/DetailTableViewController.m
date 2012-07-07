//
//  DetailTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 20.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailTableViewController.h"
#import "SmartSourceMasterViewController.h"
#import "SBJson.h"
#import "RatingTableViewViewController.h"
#import "DecisionTableViewController.h"
#import "ShowClassificationTableViewController.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "RatingTableViewViewController.h"
#import "Project+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Component+Factory.h"
#import "AlertView.h"
#import "ResultMasterViewController.h"
#import "ChartViewController.h"


@interface DetailTableViewController ()
@property (strong, nonatomic) NSArray *currentProject; //the ID of the currently displayed project
@property (strong, nonatomic) NSArray *cellNames;
@property (nonatomic) Boolean hasLoadedBefore;
@property (strong, nonatomic) IBOutlet UIButton *rateButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) SmartSourceMasterViewController *projectScreen;
@end

@implementation DetailTableViewController

@synthesize projectScreen = _projectScreen;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize hasLoadedBefore = _hasLoadedBefore;
@synthesize cellNames = _cellNames;
@synthesize rateButton = _rateButton;
@synthesize currentProject = _currentProject;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;


- (NSArray *)cellNames
{
    return [NSArray arrayWithObjects:@"ID", @"Project Name", @"Project Description", @"Category", @"Start-Date", @"End-Date", @"Creator", nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


//rateButtonPressed starts the rating of the differen Software Components of a Project
- (IBAction)rateButtonPressed:(id)sender {
    
    //show components view controller on left side
    [self.projectScreen performSegueWithIdentifier:@"componentsMenu" sender:self.projectScreen];
    
    //disable the rating button, so the segue can't be pushed a second time
    [self performSegueWithIdentifier:@"ratingScreen" sender:self];

}


- (IBAction)mainMenu:(id)sender {
        [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self.splitViewController];
}




//pass a project's information to make the detail view present its details
- (void)setProjectDetails:(NSString *)projectID
{

    //get project information
    NSDictionary *project = [self getProjectInfo:projectID];
    self.currentProject = [NSArray arrayWithObjects:projectID, [project objectForKey:@"name"], [project objectForKey:@"description"], [project objectForKey:@"category"], [project objectForKey:@"start"], [project objectForKey:@"end"], [project objectForKey:@"creator"], nil];
    
    //if the project has already been completely rated, show alert and button in navigationbar
    if ([self ratingIsCompleteForProject:projectID]) {
        
        self.navigationItem.prompt = @"This project has already been rated!";
        
        UIBarButtonItem *showResults = [[UIBarButtonItem alloc] initWithTitle:@"Show Results" style:UIBarButtonItemStyleBordered target:self action:@selector(showResults)];
        [self.navigationItem setRightBarButtonItem:showResults animated:YES];
        
    //if the project has not been completely rated and buttons are shown, remove them
    } else {
        
        self.navigationItem.prompt = nil;
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    //show rate button
    self.navigationController.navigationBarHidden = NO;
    [self.tableView reloadData];
}

- (void)showResults
{
    //perform resultssegue on projectscreen
    [self.projectScreen performSegueWithIdentifier:@"showResults" sender:self.projectScreen];
    
}


//checks weather the rating of the currently displayed project is complete or not
- (BOOL)ratingIsCompleteForProject:(NSString *)projectID
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([matches count] == 0) {
        return NO;
    }
    Project *project = [matches lastObject];
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
                    return NO;
                }
            }
        }
    }
    
    return YES;
    
}


- (void)viewDidLoad
{
    
    //set the smartsourcemasterviewcontroller's detail screen to self
    [super viewDidLoad];
    UINavigationController *masterNavigation = [self.splitViewController.viewControllers objectAtIndex:0];
    SmartSourceMasterViewController *master = (SmartSourceMasterViewController *)[masterNavigation.viewControllers objectAtIndex:0];
    master.detailScreen = self;
    self.projectScreen = master;
    
}
     


- (void)viewDidUnload
{
    
    [self setRateButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!(self.hasLoadedBefore))
    {
        //at application startup show main menu
        UINavigationController *navigation = self.navigationController;
        [navigation.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self.splitViewController];
        self.hasLoadedBefore=YES;
    }
    
    //insert root rating characteristics
    [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Software Object Communication" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication of Requirements" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication among Developers" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
    
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Business Process Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Functional Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    [AvailableCharacteristic addNewAvailableCharacteristic:@"Technical Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
    
    //save context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}


//retrieves project Information for a passed projectID
- (NSDictionary *)getProjectInfo:(NSString *)projectID
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
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getInfoForProjectObject?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
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

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.currentProject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"detailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    cell.textLabel.text = [self.cellNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.currentProject objectAtIndex:indexPath.row];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"ratingScreen"]) {
        RatingTableViewViewController *destination = segue.destinationViewController;
        destination.managedObjectContext = self.managedObjectContext;
    }
    
    
    
    if ([segue.identifier isEqualToString:@"atAGlance"]) {
        ChartViewController  *resOVC = segue.destinationViewController;
        resOVC.managedObjectContext = self.managedObjectContext;
        [resOVC setResultMasterScreen:sender]; 
    }
    

}


@end
