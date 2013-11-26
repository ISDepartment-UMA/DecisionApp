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
#import "UIColor+SmartSourceColors.h"
#import "ModalAlertViewController.h"
#import "SmartSourcePopoverController.h"
#import "VeraRomanLabel.h"

@interface ProjectSelectionViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *projectSearchBar;
@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview
@property (nonatomic) BOOL didNotUnload;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *backLabel;
@property (strong, nonatomic) IBOutlet ButtonExternalBackground *backButton;
@property (strong, nonatomic) IBOutlet UIView *backButtonBackGroundView;
@property (nonatomic, strong) ProjectPlatformModel *platformModel;
@property (nonatomic) id<ProjectSelectionViewControllerDelegate>delegate;
@property (nonatomic, strong) NSArray *projectToDelete;
@property (nonatomic, strong) UIPopoverController *popOver;


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
@synthesize delegate = _delegate;
@synthesize projectToDelete = _projectToDelete;
@synthesize popOver = _popOver;


#pragma mark getters & setters
- (void)setDelegate:(id<ProjectSelectionViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

- (void)setPlatformModel:(ProjectPlatformModel *)platformModel;
{
    _platformModel = platformModel;
}



#pragma mark inherited methods
/*
 as soon as view appears, it triggers a seperate thread that uses the model
 to retrieve all projects available from webservice and internal database
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //start seperate thread to get projects from core database and the webservice
    self.availableCells = nil;
    self.displayedCells = nil;
    [NSThread detachNewThreadSelector:@selector(getProjects) toTarget:self withObject:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.didNotUnload = YES;
    self.projectSearchBar.delegate = self;
    self.projectSearchBar.hidden = NO;
    /*
    [self.projectSearchBar setBackgroundImage:[UIImage imageNamed:@"search_bar_background.jpg"]];
    [self.projectSearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_bar_textfield.jpg"] forState:UIControlStateNormal];*/
    
    [self.projectSearchBar setTranslucent:YES];
    self.availableCells = nil;
    self.displayedCells = nil;
    
    [self.backButton setViewToChangeIfSelected:self.backButtonBackGroundView];
    [self.backLabel setText:@"\u274C"];
    
}


- (IBAction)backButtonPressed:(id)sender {
    //make modal view controller disappear
    //dsimiss and tell delegate
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate projectSelectionViewControllerHasBeenDismissedWithPlatformModel:self.platformModel];
    }];
}

# pragma mark project retrival and projectplatformmodeldelegate

//method to be called from delegate, if new projects have been found
- (void)projectArrayDidChange:(NSArray *)availableProjects
{
    self.availableCells = availableProjects;
    self.displayedCells = [self.availableCells copy];
    [self.tableView reloadData];
}

//method to be called from delegate if connection should be retried
- (BOOL)projectPlatformModelShouldKeepRetryingConnection
{
    return (self.isViewLoaded && self.view.window);
}

//seperate method to be called that gets projects from the projectplatform model
- (void)getProjects
{
    //get stored projects first
    self.availableCells = [self.platformModel getAllProjectsNamesAndSetDelegate:self];
    self.displayedCells = [self.availableCells copy];
    [self.tableView reloadData];
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



//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
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
    UIButton *deleteButton = (UIButton *)[cell viewWithTag:13];
    // Initialize array of project info
    NSArray *projectInfo = [NSArray arrayWithObjects:@"", @"", @"", @"", nil];
    //entypo - delete button in cells of core data projects
    if (indexPath.section < 1) {
        [deleteButton setTitle:@"\uE729" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(askForDeletion:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [deleteButton removeFromSuperview];
    }
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

# pragma mark delete project from core database

/*
 *  shows popover with the selection of projects from core database
 *  if yes clicked --> deletionPopoverYesPressed method called
 *  if no clicked --> deletionPopoverNoPressed method called
 */
- (void)askForDeletion:(UIButton *)sender {
    
    //show popup to ask for acknowledgement to delete project from core data
    if (self.popOver == nil) {
        //get right project
        UIView *currentView = sender;
        UITableViewCell *cell;
        while (YES) {
            if ([currentView isKindOfClass:[UITableViewCell class]]) {
                cell = (UITableViewCell *)currentView;
                break;
            } else {
                currentView = currentView.superview;
            }
        }
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        self.projectToDelete = [[self.displayedCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"Are you sure to delete the Project \"%@\"?", [self.projectToDelete objectAtIndex:1]];
        //view controller
        UIViewController *viewC = [[UIViewController alloc] init];
        //three buttons
        CGFloat heightOfView = 100;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, heightOfView)];
        [view setBackgroundColor:[UIColor whiteColor]];
        //color for all button titles
        UIColor *colorForAllTitles = [UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0];
        //font for all button titles
        UIFont *fontForAllTitles = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:15.0];
        //label
        VeraRomanLabel *label = [[VeraRomanLabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
        UIFont *labelFont = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:12.0];
        [label setText:message];
        [label setFont:labelFont];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByCharWrapping];
        [label setNumberOfLines:0];
        [label setTextColor:[UIColor colorDarkGray]];
        [view addSubview:label];
        //button1
        UIButton *noButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [noButton setFrame:CGRectMake(0, 50, 140, 50)];
        [noButton.titleLabel setFont:fontForAllTitles];
        [noButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [noButton setTitleColor:colorForAllTitles forState:UIControlStateNormal];
        [noButton setTitle:@"NO" forState:UIControlStateNormal];
        [noButton addTarget:self action:@selector(deletionPopoverNoPressed) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:noButton];
        //button2
        UIButton *yesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [yesButton setFrame:CGRectMake(140, 50, 140, 50)];
        [yesButton.titleLabel setFont:fontForAllTitles];
        [yesButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [yesButton setTitleColor:colorForAllTitles forState:UIControlStateNormal];
        [yesButton setTitle:@"YES" forState:UIControlStateNormal];
        [yesButton addTarget:self action:@selector(deletionPopoverYesPressed) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:yesButton];
        [viewC setView:view];
        
        //UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:viewC];
        SmartSourcePopoverController *tempPopover = [[SmartSourcePopoverController alloc] initWithContentViewController:viewC andTintColor:[UIColor colorWithRed:1.0 green:0.53 blue:0.0 alpha:1.0]];
        tempPopover.delegate = self;
        tempPopover.popoverContentSize=CGSizeMake(280.0, heightOfView);
        self.popOver = tempPopover;
        [self.popOver presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

/*
 *  methods that gets called when user acknowledges to delete project from core database
 *  tells model to delete project and updates displayed cells
 */
- (void)deletionPopoverYesPressed
{
    //dismiss popover
    [self.popOver dismissPopoverAnimated:YES];
    //delete project with this id from core database
    [self.platformModel deleteProjectWithID:[self.projectToDelete objectAtIndex:0]];
    //remove project from displayed cells
    NSMutableArray *displayedProjectsFromCoreMutable = [[self.displayedCells objectAtIndex:0] mutableCopy];
    [displayedProjectsFromCoreMutable removeObject:self.projectToDelete];
    self.displayedCells = [NSArray arrayWithObjects:[NSArray arrayWithArray:displayedProjectsFromCoreMutable], [self.displayedCells objectAtIndex:1], nil];
    if ([[[self.platformModel getSelectedProject] objectAtIndex:0] isEqualToString:[self.projectToDelete objectAtIndex:0]]) {
        [self.platformModel setSelectedProject:nil];
    }
    [self.tableView reloadData];
    [NSThread detachNewThreadSelector:@selector(getProjects) toTarget:self withObject:nil];
    self.popOver = nil;
    self.projectToDelete = nil;
    
}

/*
 *  methods that gets called when user declines to delete project from core database
 *  dismiss popover and set it to nil
 */
- (void)deletionPopoverNoPressed
{
    [self.popOver dismissPopoverAnimated:YES];
    self.popOver = nil;
    self.projectToDelete = nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set selected project in model to selected project
    NSArray *project = [[self.displayedCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.platformModel setSelectedProject:project];
    
    //dsimiss and tell delegate
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate projectSelectionViewControllerHasBeenDismissedWithPlatformModel:self.platformModel];
    }];
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
