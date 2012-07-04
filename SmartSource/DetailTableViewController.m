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
#import "AvailableSuperCharacteristic+Factory.h"
#import "AvailableCharacteristic+Factory.h"
#import "RatingTableViewViewController.h"


@interface DetailTableViewController ()
@property (strong, nonatomic) NSArray *currentProject; //the ID of the currently displayed project
@property (strong, nonatomic) NSArray *cellNames;
@property (nonatomic) Boolean hasLoadedBefore;
@property (strong, nonatomic) IBOutlet UIButton *rateButton;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation DetailTableViewController
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
    //perform the segue in the RootUITableViewController in order to display all SoftwareComponents on the right side
    
    UISplitViewController *splitView = self.navigationController.splitViewController;
    UINavigationController *navigation = [splitView.viewControllers objectAtIndex:0];
    SmartSourceMasterViewController *master = navigation.visibleViewController;
    [master performSegueWithIdentifier:@"componentsMenu" sender:[self.currentProject objectAtIndex:0]];
    //disable the rating button, so the segue can't be pushed a second time
    self.rateButton.hidden = YES;
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
    self.rateButton.hidden = NO;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
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
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *login = @"";
    NSString *password = @"";
    if (loginData != nil) {
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getInfoForProjectObject?login=" stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
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
    if ([segue.identifier isEqualToString:@"rateProject"]) {
        NSLog(@"%d", 5);
    }
    
    if ([segue.identifier isEqualToString:@"ratingScreen"]) {
        RatingTableViewViewController *destination = segue.destinationViewController;
        destination.managedObjectContext = self.managedObjectContext;
    }
    

}


@end
