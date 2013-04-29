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
#import "ChartViewController.h"
#import "SmartSourceAppDelegate.h"


@interface DetailTableViewController ()

//information on the left side of the cell
@property (strong, nonatomic) NSArray *cellNames;
//...and the right side
@property (strong, nonatomic) NSArray *displayedProject;
//variable necessary for the segue to main menu
@property (nonatomic) Boolean hasLoadedBefore;

//model
@property (strong, nonatomic) CodeBeamerModel *codeBeamerModel;

//available projects, either from codebeamer or from core database
@property (strong, nonatomic) NSArray *availableProjects;


@end

@implementation DetailTableViewController
@synthesize hasLoadedBefore = _hasLoadedBefore;
@synthesize cellNames = _cellNames;
@synthesize codeBeamerModel = _codeBeamerModel;
@synthesize displayedProject = _displayedProject;
@synthesize availableProjects = _availableProjects;
@synthesize masterPopoverController = _masterPopoverController;



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



- (void)showResults
{
    //perform resultssegue on projectscreen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewPerformSegueToResults" object:self];
    [self performSegueWithIdentifier:@"atAGlance" sender:self];
}


//method that is executed if the user choses to rate this project
- (void)rateProjectPressed
{
    //notify master view controller to perform segue
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewPerformSegue" object:self];
    
    //show rating screen on the right side
    [self performSegueWithIdentifier:@"ratingScreen" sender:self];
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
    
    //delete project if user resses button 0
    if (buttonIndex == 0) {
        
        //delete project
        [self.codeBeamerModel deleteProjectWithID:[self.displayedProject objectAtIndex:0]];
        
        //put button to rate the project into the navigationbar
        UIBarButtonItem *rateProject = [[UIBarButtonItem alloc] initWithTitle:@"Rate this Project" style:UIBarButtonItemStyleBordered target:self action:@selector(rateProjectPressed)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:rateProject]];
        
        //remove alert that project has been rated
        self.navigationItem.prompt = nil;
    }
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //show navigation bar
    self.navigationController.navigationBarHidden = NO;
    
    //add button to main menu
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Main Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(mainMenu:)];
    if ([self.navigationItem.leftBarButtonItems count] > 0) {
        UIBarButtonItem *buttonThere = [self.navigationItem.leftBarButtonItems lastObject];
        if (![buttonThere.title isEqualToString:@"Main Menu"]) {
            [self.navigationItem setLeftBarButtonItems: [NSArray arrayWithObjects:[self.navigationItem.leftBarButtonItems objectAtIndex:0], barbutton, nil]];
        }
    } else {
        [self.navigationItem setLeftBarButtonItems: [NSArray arrayWithObject:barbutton]];
    }
    
    //initiate code beamer model
    self.codeBeamerModel = [[CodeBeamerModel alloc] init];
        
    //option 1: projects from codebeamer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllProjects) name:@"LoadProjectsFromCodebeamer" object:nil];
    
    //option 2: stored projects from core data
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRatedProjects) name:@"LoadProjectsFromCoreData" object:nil];
}


//option 2 :stored projects from core data
- (void)showRatedProjects
{
    //get stored project from code beamer model
    self.availableProjects = [self.codeBeamerModel getStoredProjects];
    
    //notification for master view controller to get available projects
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsIntoMasterView" object:self];
}

//option 1: projects from codebeamer
- (void)showAllProjects
{
    //load projects from model in an extrathread
    //[NSThread detachNewThreadSelector:@selector(getProjectsFromModel) toTarget:self withObject:nil];
    dispatch_queue_t serialQueue = dispatch_queue_create("com.unique.name.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        self.availableProjects = [self.codeBeamerModel getAllProjectNames];
        if (self.availableProjects) {
            //notification to tell master view that this is the detail view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsIntoMasterView" object:self];
        }
    });
}

//model to be called in seperate thread to get all projects
- (void)getProjectsFromModel
{
    self.availableProjects = [self.codeBeamerModel getAllProjectNames];

    //if no projects returned, show alert
    if (!self.availableProjects) {

        NSString *message = @"Communication to server failed. Please check your login data!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];

        
    //else load projects into masterview
    } else {
        
        //notification to tell master view that this is the detail view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsIntoMasterView" object:self];
    }
    
    
}


//display project at index that was selected in master view
- (void)selectProjectWithID:(NSString *)projectID
{

    self.displayedProject = [self.codeBeamerModel getProjectInfo:projectID];
    [self.tableView reloadData];
    
    //show rate button
    [self.navigationController setNavigationBarHidden:NO];
    
    //if project has been selected, dismiss popovercontroller
    [self.masterPopoverController dismissPopoverAnimated:YES];
    
    //handle buttons
    [self handleRatingButtonsInNavigationBar];
}



//public method to be called from masterviewcontroller to retrieve all available projects
- (NSArray *)getAvailableProjects
{
    return [self.availableProjects copy];
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
    [self.splitViewController setDelegate:self];
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
    //if no project is selected, don't show any button
    if (self.displayedProject == nil) {
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }

    //put button to rate the project into the navigationbar
    UIBarButtonItem *rateProject = [[UIBarButtonItem alloc] initWithTitle:@"Rate this Project" style:UIBarButtonItemStyleBordered target:self action:@selector(rateProjectPressed)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObject:rateProject]];
    
    //if the project has already been completely rated, show alert and button in navigationbar
    if ([self.codeBeamerModel ratingIsCompleteForProject:[self.displayedProject objectAtIndex:0]]) {
        
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
        
        //hide buttons
        self.navigationItem.prompt = nil;
        
    }

}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    
    barButtonItem.title = NSLocalizedString(@"Projects", @"Projects");
    if ([self.navigationItem.leftBarButtonItems count] > 0) {
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: barButtonItem, [self.navigationItem.leftBarButtonItems objectAtIndex:0], nil]];
    } else {
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:barButtonItem]];
    }
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:[self.navigationItem.leftBarButtonItems lastObject]]];
    self.masterPopoverController = nil;
}







#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.displayedProject count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"detailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    cell.textLabel.text = [self.cellNames objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.displayedProject objectAtIndex:indexPath.row];
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //nothing
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //segue to rating screen
    if ([segue.identifier isEqualToString:@"ratingScreen"]) {
        
        //pass selected project to rating screen
        RatingTableViewViewController *destination = segue.destinationViewController;
        [destination setProject:[self.displayedProject objectAtIndex:0]];
        
        //pass barbuttonitem that hides popover controller to rating screen
        if([self.navigationItem.leftBarButtonItems count] > 1) {
            UIBarButtonItem *barButtonItem = [self.navigationItem.leftBarButtonItems objectAtIndex:0];
            barButtonItem.title = NSLocalizedString(@"Components", @"Components");
            destination.navigationItem.leftBarButtonItem = barButtonItem;
            destination.masterPopoverController = self.masterPopoverController;
            
        }
    }
    
    
    //segue to results screen
    if ([segue.identifier isEqualToString:@"atAGlance"]) {
        
        //pass selected project to results screen
        ChartViewController  *resOVC = segue.destinationViewController;
        [resOVC initializeClassificationForProject:[self.displayedProject objectAtIndex:0]];
        
        //pass barbuttonitem that hides popover controller to result screen
        if([self.navigationItem.leftBarButtonItems count] > 1) {
            UIBarButtonItem *barButtonItem = [self.navigationItem.leftBarButtonItems objectAtIndex:0];
            barButtonItem.title = NSLocalizedString(@"Result Overview", @"Result Overview");
            resOVC.navigationItem.leftBarButtonItem = barButtonItem;
            resOVC.masterPopoverController = self.masterPopoverController;
            
        }
    }
    

}


@end
