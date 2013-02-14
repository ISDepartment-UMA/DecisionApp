//
//  SmartSourceMasterViewController.m
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmartSourceMasterViewController.h"
#import "Json/SBJson.h"
#import "DetailTableViewController.h"
#import "ComponentsTableViewController.h"
#import "ResultMasterViewController.h"
#import "RatingTableViewViewController.h"

//unnötig?
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "Project+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Component+Factory.h"
#import "AlertView.h"


@interface SmartSourceMasterViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *projectSearchBar;

@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview
@property (strong, nonatomic) NSString * selectedProject;


@end

@implementation SmartSourceMasterViewController
@synthesize selectedProject = _selectedProject;
@synthesize detailScreen = _detailScreen;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize detailViewController = _detailViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize projectSearchBar = _projectSearchBar;
@synthesize availableCells = _availableCells;
@synthesize displayedCells = _displayedCells;


- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //call loadProjects in seperate thread to retrieve projects
    //[NSThread detachNewThreadSelector:@selector(loadProjects) toTarget:self withObject:nil];
    
    //search bar
    self.projectSearchBar.delegate = self;
    
    //add observer so data is reloaded, once the main menu disappears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllProjects) name:@"UpdateMaserViewFromCodeBeamer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRatedProjects) name:@"UpdateMasterViewFromCoreData" object:nil];
}

//method to be called in seperate thread that retrieves information about all projects from code beamer
- (void)loadProjectsFromCodeBeamer
{
    self.availableCells = [self getAllProjectNames];
    self.displayedCells = self.availableCells;
    [self.tableView reloadData];
    
}

//method that loads all projects if main menu is poped
- (void)showAllProjects
{
    [self.detailScreen setProjectDetails:nil];
    [NSThread detachNewThreadSelector:@selector(loadProjectsFromCodeBeamer) toTarget:self withObject:nil];
}

- (void)showRatedProjects
{
    [self.detailScreen setProjectDetails:nil];

    //get all projects from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //initiate array of available projects
    NSMutableArray *availableProjects = [NSMutableArray array];
    
    
    //put id, name and description of all projects into available projects
    for (int i=0; i<[matches count]; i++) {
        Project *currProject = [matches objectAtIndex:i];
        [availableProjects addObject:[NSArray arrayWithObjects:currProject.projectID, currProject.name, currProject.descr, nil]];
    }
    
    
    
    self.availableCells = [availableProjects copy];
    self.displayedCells = self.availableCells;
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //if view appears, set displayed cells to available cells, this avoids problems when poping back to project selection
    self.displayedCells = self.availableCells;
    self.projectSearchBar.text = @"";
    
    if (![self.detailScreen.navigationController.visibleViewController isKindOfClass:[self.detailScreen class]]) {
        [self.detailScreen.navigationController popToViewController:self.detailScreen animated:NO];
    }
}




- (void)viewDidUnload
{
    [self setProjectSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)mainMenuPressed:(id)sender {
    [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self];
}

#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.displayedCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"projectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSArray *projectInfo = [NSArray arrayWithObjects:@"Error", @"Error", @"Error", @"Error", nil];
    
    //check if the communication to the server returned projects
    if ([[self.displayedCells objectAtIndex:indexPath.row] count] > 1) {
        projectInfo = [self.displayedCells objectAtIndex:indexPath.row];
        
    //else show error message
    } else {
        NSString *message = @"Communication to server failed. Please check your login data!";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    
    
    cell.textLabel.text = [projectInfo objectAtIndex:1];


    return cell;
}

// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
- (NSArray *)getAllProjectNames
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
    NSString *url = [[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8081/axis2/services/DataFetcher/getAllProjects?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&response=application/json"];
    
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *projectsTotal = [responsedic objectForKey:@"return"];
    
    //difference between one returned project and more than one
    @try {
        NSEnumerator *projects = [projectsTotal objectEnumerator];
        id next = [projects nextObject];
        
        //only one project returned
        if ([next isKindOfClass:[NSArray class]]) {
            NSString *id = [NSString stringWithFormat:@"%d", [[next objectAtIndex:0] integerValue]];
            NSString *name = [next objectAtIndex:1];
            NSString *description = [next objectAtIndex:2];

            return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        }
        
        //more than one project returned
        NSMutableArray *allProjects;
        NSEnumerator *oneproject = [next objectEnumerator];
        
        //retrieve project name, id and description in 2-dimensional array
        //0: ID 1:Name 2:Description
        NSArray *current = [oneproject nextObject];
        NSString *id = [NSString stringWithFormat:@"%d", [[current objectAtIndex:0] integerValue]];
        NSString *name = [current objectAtIndex:1];
        NSString *description = [current objectAtIndex:2];

        allProjects = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        
        NSDictionary *temp;
        while ((temp = [projects nextObject]) != nil) {
            NSEnumerator *temp2 = [temp objectEnumerator];
            NSArray *current = [temp2 nextObject];
            NSString *id = [NSString stringWithFormat:@"%d", [[current objectAtIndex:0] integerValue]];
            NSString *name = [current objectAtIndex:1];
            NSString *description = [current objectAtIndex:2];
            [allProjects addObject:[NSMutableArray arrayWithObjects:id, name, description, nil]];
        }
        
        //return
        return allProjects;
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:@"", @"Fehler!", @"",  nil]];
    }
}



#pragma mark - Handling Search Bar Query

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.displayedCells = nil;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *output = [NSMutableArray array];
    if ([searchText isEqualToString:@""] || searchText == nil) {
        self.displayedCells = nil;
        [self.tableView reloadData];
        return;
    }
    
    NSArray *cell;
    for (cell in self.availableCells)
    {
        NSComparisonResult result = [[cell objectAtIndex:1] compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchText.length)];
        if (result == NSOrderedSame) {
            [output addObject:cell];
        }
    }
    self.displayedCells = [output copy];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.displayedCells = [self.availableCells copy];
    @try {
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
    }
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}






#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set detail screen
    NSArray *tmpProjectInfo = [self.displayedCells objectAtIndex:indexPath.row];
    [self.detailScreen setProjectDetails:[tmpProjectInfo objectAtIndex:0]];
    self.selectedProject = [tmpProjectInfo objectAtIndex:0];
}
    

    

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"componentsMenu"]) {
        ComponentsTableViewController *destination = segue.destinationViewController;
        destination.managedObjectContext = self.managedObjectContext;
        [destination setProject:self.selectedProject];
    }
    
    if ([segue.identifier isEqualToString:@"showResults"]) {
        ResultMasterViewController *resultMVC = segue.destinationViewController;
        resultMVC.managedObjectContext = self.managedObjectContext;
        [resultMVC prepareResultsForProject:self.selectedProject];
        
        [self.detailScreen performSegueWithIdentifier:@"atAGlance" sender:resultMVC];
    }
}


@end
