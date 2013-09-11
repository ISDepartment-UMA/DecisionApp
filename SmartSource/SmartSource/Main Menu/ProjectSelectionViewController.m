//
//  ProjectSelectionViewController.m
//  SmartSource
//
//  Created by Lorenz on 01.07.13.
//
//

#import "ProjectSelectionViewController.h"
#import "ModalViewControllerPresenter.h"
#import "MainMenuViewController.h"
#import "SmartSourceTableViewCell.h"
#import "ButtonExternalBackground.h"

@interface ProjectSelectionViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *projectSearchBar;
@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview
@property (nonatomic) BOOL didNotUnload;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *backLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackGroundView;

@end

@implementation ProjectSelectionViewController
@synthesize platformModel = _platformModel;
@synthesize projectSearchBar = _projectSearchBar;
@synthesize availableCells = _availableCells;
@synthesize displayedCells = _displayedCells;
@synthesize tableView = _tableView;
@synthesize backLabel = _backLabel;
@synthesize backButton = _backButton;
@synthesize backButtonBackGroundView = _backButtonBackGroundView;




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //start seperate thread to get projects from core database and the webservice
    self.availableCells = nil;
    self.displayedCells = nil;
    [NSThread detachNewThreadSelector:@selector(getProjects) toTarget:self withObject:nil];
    
    //while thread is running, wait
    while (!self.displayedCells) {
        //do nothing
    }
    
    //in case projects from webservice are empty, start seperate thread that looks for them
    if ([[self.availableCells objectAtIndex:1] count] < 1) {
        [NSThread detachNewThreadSelector:@selector(keepLookingForProjects) toTarget:self withObject:nil];
    }
    
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.didNotUnload = YES;
    self.projectSearchBar.delegate = self;
    self.projectSearchBar.hidden = NO;
    self.availableCells = nil;
    self.displayedCells = nil;
    
    [self.backButton setViewToChangeIfSelected:self.backButtonBackGroundView];
    [self.backLabel setText:@"\u274C"];
    
}


//method to be called in seperate thread that keeps looking for projects from the webservice
- (void)keepLookingForProjects
{
    //keep looking for projects
    while (([[self.availableCells objectAtIndex:1] count] < 1) && self.didNotUnload) {

        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getProjects) object:nil];
        [thread start];
        
        while ([thread isExecuting]) {
            //do nothing
        }
    }
    
    self.displayedCells = [self.availableCells copy];
    [self.tableView reloadData];
}

- (IBAction)backButtonPressed:(id)sender {
    //make modal view controller disappear
    [self dismissModalViewControllerAnimated:YES];
}



//seperate method to be called that gets projects from the projectplatform model
- (BOOL)getProjects
{
    self.availableCells = [self.platformModel getAllProjectNames];
    self.displayedCells = [self.availableCells copy];    
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Stored on Device";
    } else {
        return @"From WebService";
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, tableView.frame.size.width - 10, 20)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"BitstreamVeraSans-Bold" size:15.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    
    if (section == 0) {
        [label setText:@"Stored on Device"];
    } else {
         [label setText:@"From WebService"];
    }
    [headerView addSubview:label]; 
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.availableCells) {
        
        //if no projects from webservice available, return 1 for activity indicator
        if (([[self.displayedCells objectAtIndex:section] count] == 0) && (section == 1)) {
            return 1;
        }
        
        //else return number of projects
        return [[self.displayedCells objectAtIndex:section] count];
        
    //if no projects available at all, return 1 --> activity indicator
    } else {
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cellSubView = nil;
    UITableViewCell *cell;
    
    //while the cellsubview on the dequed cell does not exist, get a new cell
    //this could be, since the cell subview is removed if an activity indicator is added
    while (!cellSubView) {
        
        //get cell
        NSString *cellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        
        //get subview of cell
        cellSubView = [cell viewWithTag:22];
    }
    
    
    
    
    //get text label of cell
    UILabel *textLabel = (UILabel *)[cellSubView viewWithTag:12];
    
    

    // Configure the cell...
    // Initialize array of project info
    NSArray *projectInfo = [NSArray arrayWithObjects:@"", @"", @"", @"", nil];
    
    
    //check if the communication to the server returned projects
    if (self.displayedCells && ([[self.displayedCells objectAtIndex:indexPath.section] count] > 0)) {
        
        //get project info
        projectInfo = [[self.displayedCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        //put project info into cell
        textLabel.text = [projectInfo objectAtIndex:1];
        
        return cell;
        
        
        
    //else show activity indicator
    } else {
        
        [cellSubView removeFromSuperview];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(((cell.frame.size.width/2)-20), 0, 40, 40);
        [cell addSubview:spinner];
        [spinner startAnimating];
        return cell;
        
    }
    
   
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    //set selected project in model to selected project
    NSArray *project = [[self.displayedCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.platformModel setSelectedProject:project];
    
    //make modal view controller disappear
    [self dismissModalViewControllerAnimated:YES];
    
    
    //check presenting view controller
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)self.presentingViewController;
        
        if ([[navi.viewControllers lastObject] isKindOfClass:[MainMenuViewController class]]) {
            MainMenuViewController *main = (MainMenuViewController *)[navi.viewControllers lastObject];
            //[main modalViewControllerHasBeenDismissed];
            [NSThread detachNewThreadSelector:@selector(modalViewControllerHasBeenDismissed) toTarget:main withObject:nil];
        }
    }
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    self.didNotUnload = NO;
    [super viewDidDisappear:animated];
}
- (void)viewDidUnload {
    [self setProjectSearchBar:nil];
    [self setTableView:nil];
    [self setBackLabel:nil];
    [self setBackButton:nil];
    [self setBackButtonBackGroundView:nil];
    [super viewDidUnload];
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
    NSMutableArray *outputOnDevice0 = [NSMutableArray array];
    NSMutableArray *outputFromService1 = [NSMutableArray array];
    if ([searchText isEqualToString:@""] || searchText == nil) {
        self.displayedCells = self.availableCells;
        [self.tableView reloadData];
        return;
    }
    
    NSArray *cell;
    for (cell in [self.availableCells objectAtIndex:0])
    {
        NSComparisonResult result = [[cell objectAtIndex:1] compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchText.length)];
        if (result == NSOrderedSame) {
            [outputOnDevice0 addObject:cell];
        }
    }
    
    for (cell in [self.availableCells objectAtIndex:1])
    {
        NSComparisonResult result = [[cell objectAtIndex:1] compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchText.length)];
        if (result == NSOrderedSame) {
            [outputFromService1 addObject:cell];
        }
    }
    
    NSArray *output0 = [outputOnDevice0 copy];
    NSArray *output1 = [outputFromService1 copy];
    
    self.displayedCells = [NSArray arrayWithObjects:output0, output1, nil];
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

@end
