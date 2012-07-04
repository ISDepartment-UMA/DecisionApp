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
#import "Characteristic+Factory.h"

@interface ComponentsTableViewController ()

@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableDictionary *ratedComponents;
@property (strong, nonatomic) IBOutlet UIButton *saveProjectButton;
@property (strong, nonatomic) NSString *currentProject;



@end



@implementation ComponentsTableViewController
//synthesize
@synthesize availableCells = _availableCells;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize ratedComponents = _ratedComponents;
@synthesize saveProjectButton = _saveProjectButton;
@synthesize currentProject = _currentProject;


//getter for ratedComponents that initializes the NSDictionary
- (NSMutableDictionary *)ratedComponents
{
    if (!_ratedComponents) {
        _ratedComponents = [NSMutableDictionary dictionary];
        return _ratedComponents;
    }
    else {
        return _ratedComponents;
    }
}



//saves the rating of components that belong to the project in the core database
//triggered by pressing the saveProjectButton, which is only visible, when all components have been rated
- (IBAction)saveProjectRating:(id)sender {

    //iterate all components of ratedComponents
    NSEnumerator *componentEnumerator = [self.ratedComponents keyEnumerator];
    NSString *componentID = nil;
    while ((componentID = componentEnumerator.nextObject) != nil) {
        
        //iterate through all supercharacteristics of each component
        NSEnumerator *superCharEnumerator = [[self.ratedComponents objectForKey:componentID] keyEnumerator];
        NSString *superCharName = nil;
        while ((superCharName = superCharEnumerator.nextObject) != nil) {
            
            //get array with supercharacteristic's properties
            NSArray  *superCharDetail = [[self.ratedComponents objectForKey:componentID] objectForKey:superCharName];
            //get weight
            NSNumber *weight = [superCharDetail objectAtIndex:0];
            
            //iterate through all characteristics
            NSEnumerator *characteristicsNames = [[superCharDetail objectAtIndex:1] keyEnumerator];
            NSString *characteristicsName = nil;
            while ((characteristicsName = characteristicsNames.nextObject) != nil) {
                
                NSNumber *charValue = [[superCharDetail objectAtIndex:1] objectForKey:characteristicsName];
                [Characteristic addNewCharacteristic:characteristicsName withValue:charValue toSuperCharacteristic:superCharName withWeight:weight andComponent:componentID andProject:self.currentProject andManagedObjectContext:self.managedObjectContext];
                
            }
            
        }
    }
    
    
    //save context
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Operation Successful" message:@"The Project rating was saved successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}




//method to set the project, the components should be retrieved from
- (void)setProject:(NSString *)projectID
{
    self.availableCells = [self getAllComponentsForProjectId:projectID];
    self.currentProject = projectID;
    [self.tableView reloadData];
}


//recieve ratings from RatingTableViewController and store it in array
- (void)sendRating:(NSDictionary *)rating forComponent:(NSString *)componentID
{
    [self.ratedComponents setObject:rating forKey:componentID];
    if ([self.ratedComponents count] == [self.availableCells count]) {
        self.saveProjectButton.hidden = NO;
    }
    
    [self.tableView reloadData];


}


//import all components of a project from the webservice
- (NSArray *)getAllComponentsForProjectId:(NSString *)projectID
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
    
    //building the url
    NSString *url = [[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getAllComponentsForProject?login=" stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&projectID="] stringByAppendingString:projectID] stringByAppendingString:@"&response=application/json"];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewDidUnload
{
    [self setSaveProjectButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    if ([self.ratedComponents objectForKey:[componentInfo objectAtIndex:0]] != nil) {
        cell.detailTextLabel.text = @"Rating Complete";
    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */








#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    //set the currently displayed component in the rating table view controller
    RatingTableViewViewController *ratingTVC = (RatingTableViewViewController *)[[self.navigationController.splitViewController.viewControllers objectAtIndex:1] visibleViewController];
    NSString *componentID = [[self.availableCells objectAtIndex:indexPath.row] objectAtIndex:0];
    [ratingTVC setComponent:componentID];



}

@end
