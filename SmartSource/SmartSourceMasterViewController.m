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
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"


@interface SmartSourceMasterViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview

@end

@implementation SmartSourceMasterViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize detailViewController = _detailViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize searchBar;
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
    self.detailViewController = (SmartSourceDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.availableCells = [self getAllProjectNames];
    self.displayedCells = self.availableCells;
    self.searchBar.delegate = self;
    
    //add observer so data is reloaded, once the main menu disappears
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScreen) name:@"UpdateMaserView" object:nil];
}

- (void)updateScreen
{
    self.availableCells = [self getAllProjectNames];
    self.displayedCells = self.availableCells;
    [self.tableView reloadData];
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

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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
    
    if ([[projectInfo objectAtIndex:3] boolValue]) {
        cell.detailTextLabel.text = @"Rating Complete";
    }


    return cell;
}

// JSON query to get all project ids, names and descriptions
//@return: two dimensional array
// 1st dimension: project
// 2nd dimension: property: 0:ID - 1:Name - 2:Description -3:BOOL if it's already in the database
- (NSArray *)getAllProjectNames
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
    NSString *url = [[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getAllProjects?login=" stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&response=application/json"];
    
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
            NSNumber *rated = [NSNumber numberWithBool:NO];
            return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, rated, nil]];
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
        NSNumber *rated = [NSNumber numberWithBool:NO];
        allProjects = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:id, name, description, rated, nil]];
        
        NSDictionary *temp;
        while ((temp = [projects nextObject]) != nil) {
            NSEnumerator *temp2 = [temp objectEnumerator];
            NSArray *current = [temp2 nextObject];
            NSString *id = [NSString stringWithFormat:@"%d", [[current objectAtIndex:0] integerValue]];
            NSString *name = [current objectAtIndex:1];
            NSString *description = [current objectAtIndex:2];
            NSNumber *rated = [NSNumber numberWithBool:NO];
            [allProjects addObject:[NSMutableArray arrayWithObjects:id, name, description, rated, nil]];
        }
        
        //return
        [self checkForStoredRatings:allProjects];
        return allProjects;
    }
    @catch (NSException *exception) {
        return [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObjects:@"", @"Fehler!", @"", [NSNumber numberWithBool:NO],  nil]];
    }
}


//check for all projects if there is already a project with the same id in the core database
//if there is one, change the bool at the project's information array to YES
- (NSArray *)checkForStoredRatings:(NSArray *)projects
{
    for (int i=0; i<[projects count]; i++) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
        request.predicate = [NSPredicate predicateWithFormat:@"id =%@", [[projects objectAtIndex:i] objectAtIndex:0]];
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        if ([matches count] >0) {
            [[projects objectAtIndex:i] replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool:YES]];
        }
    }
    
    return projects;
    
    
    
    
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
    NSMutableArray *result = [NSMutableArray array];
    if ([searchText isEqualToString:@""] || searchText == nil) {
        self.displayedCells = nil;
        [self.tableView reloadData];
        return;
    }
    
    NSInteger counter = 0;
    for (NSArray *cell in self.availableCells) {
        @autoreleasepool {
            NSRange r = [[cell objectAtIndex:1] rangeOfString:searchText];
            if (r.location != NSNotFound) {
                [result addObject:cell];
            }
            counter++;
        }
    }
    self.displayedCells = [result copy];
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

    //change detail view
    //if it hasn't been rated, show details in detail view
    //otherwise show results from last rating
    if (![[[self.displayedCells objectAtIndex:indexPath.row] objectAtIndex:3] boolValue]) {
        UINavigationController *navigation = [[self.splitViewController viewControllers] objectAtIndex:1];
        if ([navigation.viewControllers.lastObject isKindOfClass:[DetailTableViewController class]]) {
            DetailTableViewController *detail = navigation.viewControllers.lastObject;
            NSArray *tmpInfo = [self.displayedCells objectAtIndex:[indexPath row]];
            [detail setProjectDetails:[tmpInfo objectAtIndex:0]];
        }
    }
    

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"componentsMenu"]) {
        ComponentsTableViewController *destination = segue.destinationViewController;
        destination.managedObjectContext = self.managedObjectContext;
        [destination setProject:sender];
    }
}


@end
