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
@property (strong, nonatomic) NSArray *currentProject; //array of details about the current project
@property (strong, nonatomic) NSArray *cellNames;
@property (nonatomic) Boolean hasLoadedBefore;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) SmartSourceMasterViewController *projectScreen;
@end

@implementation DetailTableViewController

@synthesize projectScreen = _projectScreen;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize hasLoadedBefore = _hasLoadedBefore;
@synthesize cellNames = _cellNames;
@synthesize currentProject = _currentProject;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;


//returns names for detail description of project
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



- (IBAction)mainMenu:(id)sender {
        [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self.splitViewController];
}




//pass a project's information to make the detail view present its details
- (void)setProjectDetails:(NSString *)projectID
{
    if (projectID == nil) {
        
        //show nothing in table view and hide navigation bar
        self.currentProject = nil;
        [self.navigationController setNavigationBarHidden:YES];
    } else {
        
        
        //get project information
        NSDictionary *project = [self getProjectInfo:projectID];
        self.currentProject = [NSArray arrayWithObjects:projectID, [project objectForKey:@"name"], [project objectForKey:@"description"], [project objectForKey:@"category"], [project objectForKey:@"start"], [project objectForKey:@"end"], [project objectForKey:@"creator"], nil];
        
        
        //put rating buttons into navigation bar
        [self handleRatingButtonsInNavigationBar];
        
        //show rate button
        [self.navigationController setNavigationBarHidden:NO];
    }

    
    
    
    [self.tableView reloadData];
}

- (void)showResults
{
    //perform resultssegue on projectscreen
    [self.projectScreen performSegueWithIdentifier:@"showResults" sender:self.projectScreen];
    
}


//method that is executed if the user choses to rate this project
- (void)rateProjectPressed
{
    //show components view controller on left side
    [self.projectScreen performSegueWithIdentifier:@"componentsMenu" sender:self.projectScreen];
    
    //show rating screen on the right side
    [self performSegueWithIdentifier:@"ratingScreen" sender:self];
    
    //post notification to select the first component in the components menu
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ComponentTableViewControllerSelect" object:nil userInfo:[NSDictionary dictionary]];
    
}


//method called when the user selects to delete the project rating
- (void)deleteProject
{
    //show alert that asks user if he really wants to delete the project
    NSString *message = @"Do you really want to delete the stored Project Rating?";
    AlertView * alert = [[AlertView alloc] initWithTitle:@"Delete Rating" message:message delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

//reacts to the user's selection in the alert view to delete the project rating
- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    
    //if delete button was pressed
    if (buttonIndex == 0) {
        
        //then delete the current rating from the core database
        //look for project in core database
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
        request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", [self.currentProject objectAtIndex:0]];
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        //delete project
        //deletion rule in core database is set to cascade, so deleting the project will delete all components, supercharacteristics and characteristics
        [self.managedObjectContext deleteObject:[matches objectAtIndex:0]];
        
        //save context
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        //put button to rate the project into the navigationbar
        UIBarButtonItem *rateProject = [[UIBarButtonItem alloc] initWithTitle:@"Rate this Project" style:UIBarButtonItemStyleBordered target:self action:@selector(rateProjectPressed)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:rateProject]];
        
        //remove alert that project has been rated
        self.navigationItem.prompt = nil;
    }
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
    self.navigationController.navigationBarHidden = YES;

    
    
}
     


- (void)viewDidUnload
{
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
    
    
    //put rating buttons into navigation bar
    [self handleRatingButtonsInNavigationBar];


}


//puts buttons into navigation bar
//for already rated projects: rate project, show results, delete project
//for projects without a rating stored: rate project
- (void)handleRatingButtonsInNavigationBar
{


    
    //put button to rate the project into the navigationbar
    UIBarButtonItem *rateProject = [[UIBarButtonItem alloc] initWithTitle:@"Rate this Project" style:UIBarButtonItemStyleBordered target:self action:@selector(rateProjectPressed)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:rateProject]];
    
    //if the project has already been completely rated, show alert and button in navigationbar
    if ([self ratingIsCompleteForProject:[self.currentProject objectAtIndex:0]]) {
        
        self.navigationItem.prompt = @"This project has already been rated!";
        
        //button to show results
        UIBarButtonItem *showResults = [[UIBarButtonItem alloc] initWithTitle:@"Show Results" style:UIBarButtonItemStyleBordered target:self action:@selector(showResults)];
        NSMutableArray *buttonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        [buttonItems addObject:showResults];
        
        //button to delete rating
        UIBarButtonItem *deleteProject = [[UIBarButtonItem alloc] initWithTitle:@"Delete Rating" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteProject)];
        [deleteProject setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
        [buttonItems addObject:deleteProject];
        
        //add buttons to navigation bar
        [self.navigationItem setRightBarButtonItems:[buttonItems copy] animated:YES];
        
        //if the project has not been completely, remove the alert
    } else {
        
        self.navigationItem.prompt = nil;
        
    }
    
    if (self.currentProject == nil) {
        self.navigationItem.rightBarButtonItem = nil;
        [self.navigationController setNavigationBarHidden:NO];
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
