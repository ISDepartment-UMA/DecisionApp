//
//  SmartSourceMasterViewController.m
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmartSourceMasterViewController.h"
#import "DetailTableViewController.h"
#import "Component+Factory.h"






@interface SmartSourceMasterViewController ()
@property (strong, nonatomic) IBOutlet UISearchBar *projectSearchBar;

@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSArray *componentClassification;


@end

@implementation SmartSourceMasterViewController
@synthesize detailScreen = _detailScreen;
@synthesize detailViewController = _detailViewController;
@synthesize projectSearchBar = _projectSearchBar;
@synthesize availableCells = _availableCells;
@synthesize displayedCells = _displayedCells;
//"projects", "components", "results"
@synthesize state = _state;
@synthesize ratingScreen = _ratingScreen;
@synthesize resultScreen = _resultScreen;
@synthesize componentClassification = _componentClassification;


- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.state = @"projects";
    //search bar
    self.projectSearchBar.delegate = self;
    
    
}


- (void)getDataFromDetailScreen
{
    //projects
    if ([self.detailScreen.navigationController.visibleViewController isKindOfClass:[DetailTableViewController class]]) {
        [self.navigationItem setLeftBarButtonItems:nil];
        self.state = @"projects";
        self.projectSearchBar.text = @"";
        self.navigationItem.title = @"Projects";
        self.projectSearchBar.hidden = NO;
        self.availableCells = [self.detailScreen getAvailableProjects];
        self.displayedCells = [self.availableCells copy];
        [self.tableView reloadData];
        
     
    //components
    } else if ([self.detailScreen.navigationController.visibleViewController isKindOfClass:[RatingTableViewViewController class]]) {
        self.ratingScreen = (RatingTableViewViewController *)self.detailScreen.navigationController.visibleViewController;
        self.state = @"components";
        self.navigationItem.title = @"Components";
        //get available components from detail screen
        self.availableCells = [self.ratingScreen getAvailableComponents];
        self.displayedCells = self.availableCells;
        self.projectSearchBar.text = @"";
        //self.projectSearchBar.hidden = YES;
        [self.tableView reloadData];
        
        //add back button
        //add button to main menu
        UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Projects" style:UIBarButtonItemStyleBordered target:self action:@selector(backToProjects)];
        [self.navigationItem setLeftBarButtonItem:barbutton];
        
        //if no components in the project, alert!
        if ([self.availableCells count] == 0) {
            NSString *message = @"No Components Available in this Project";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
            
        //select the appropriate component that is currently displayed in the rating screen
        } else {
            NSInteger comp = [self.ratingScreen indexOfDisplayedComponent];
            NSIndexPath *index = [NSIndexPath indexPathForRow:comp inSection:0];
            [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
        
    

    //results
    } else if ([self.detailScreen.navigationController.visibleViewController isKindOfClass:[ChartViewController class]]) {
        self.state = @"results";
        self.navigationItem.title = @"Results Overview";
        self.resultScreen = (ChartViewController *)self.detailScreen.navigationController.visibleViewController;
        self.availableCells = [NSArray arrayWithObjects:@"At One Glance", @"A Classified", @"B Classified", @"C Classified", @"Detailed Decision Table" ,nil];
        self.displayedCells = self.availableCells;
        self.projectSearchBar.hidden = YES;
        self.componentClassification = [self.resultScreen getClassificationForCurrentProject];
        [self.tableView reloadData];
        
        
        //check if there is a rating screen in the detailnavigationcontroller
         //if there is a RatingTableViewController in the Controller stack of the NavigationController of the detail side then pop to it
         //else pop to root view controller
         
         RatingTableViewViewController *ratingController = nil;
         for (id controller in self.detailScreen.navigationController.viewControllers) {
             if ([controller isKindOfClass:[RatingTableViewViewController class]]) {
                ratingController = controller;
                break;
             }
         }
        
        if (ratingController) {
            self.ratingScreen = ratingController;
            //add button back to rating
            UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Rating" style:UIBarButtonItemStyleBordered target:self action:@selector(backToRating)];
            [self.navigationItem setLeftBarButtonItem:barbutton];
        } else {
            //add button back to projects
            UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"Projects" style:UIBarButtonItemStyleBordered target:self action:@selector(backToProjects)];
            [self.navigationItem setLeftBarButtonItem:barbutton];
            self.ratingScreen = nil;
        }
        
        
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionTop];
        
    }
}


//gets called if the user wants to go back to projects
- (void)backToProjects
{
    //pop detail view back to detailscreen
    [self.detailScreen.navigationController popToViewController:self.detailScreen animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];

}


//executed when user wants to pop back to the rating screen
- (void)backToRating
{
    [self.detailScreen.navigationController popToViewController:self.ratingScreen animated:YES];
}

- (void)selectComponentOnRatingScreen:(NSNotification *)notification
{
    if ([self.state isEqualToString:@"components"]) {
        
        NSLog(@"backcomponentcheck");
        NSLog(@"alles klar");
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDataFromDetailScreen) name:@"MasterViewGet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectComponentOnRatingScreen:) name:@"selectComponentOnRatingScreen" object:nil];

    
}






- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //if view appears, set displayed cells to available cells, this avoids problems when poping back to project selection
    self.displayedCells = self.availableCells;
    self.projectSearchBar.text = @"";
    [self.tableView reloadData];
    [self getDataFromDetailScreen];
    
    
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


#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.availableCells) {
        return [self.displayedCells count];
        
    //if no projects available show activity indicator
    } else if ([self.state isEqualToString:@"projects"]) {
        return 1;
        
    } else {
        return 0;
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"projectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    //project
    if ([self.state isEqualToString:@"projects"]) {
        // Configure the cell...
        NSArray *projectInfo = [NSArray arrayWithObjects:@"", @"", @"", @"", nil];
        
        
        //check if the communication to the server returned projects
        if (self.availableCells) {
            if ([[self.displayedCells objectAtIndex:indexPath.row] count] > 1) {
                projectInfo = [self.displayedCells objectAtIndex:indexPath.row];
            }
        } else {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            spinner.frame = CGRectMake(((cell.frame.size.width/2)-20), 0, 40, 40);
            [cell addSubview:spinner];
            [spinner startAnimating];
        }
        cell.textLabel.text = [projectInfo objectAtIndex:1];
        cell.detailTextLabel.text = @"";
    
        
    //component
    } else if ([self.state isEqualToString:@"components"]) {
        if ([self.availableCells count]>0) {
            Component *comp = [self.displayedCells objectAtIndex:indexPath.row];
            cell.textLabel.text = comp.name;
            cell.detailTextLabel.text = @"";
        } else {
            cell.textLabel.text =@"";
        }
        
    
        
    //results
    } else if ([self.state isEqualToString:@"results"]) {
        // Configure the cell...
        cell.textLabel.text = [self.availableCells objectAtIndex:indexPath.row];
        
        if ((indexPath.row >0) && (indexPath.row <4) && (self.componentClassification)) {
            int number = [[self.componentClassification objectAtIndex:(indexPath.row-1)] count];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", number];
        }
    }


    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //make keyboard disappear
    [self.view endEditing:YES];
    
    
    if ([self.state isEqualToString:@"projects"]) {
        //set detail screen
        [self.detailScreen selectProjectWithID:[[self.displayedCells objectAtIndex:indexPath.row] objectAtIndex:0]];
    } else if ([self.state isEqualToString:@"components"]) {
        //set the currently displayed component in the rating table view controller
        [self.ratingScreen setComponent:indexPath.row];
    } else if ([self.state isEqualToString:@"results"]) {
        
        [self.resultScreen.navigationController popToViewController:self.resultScreen animated:NO];
        
        //if user wants to see the decision talbe
        if (indexPath.row ==4) {
            [self.resultScreen showDecisionTable];
        }
        
        //if user wants to see the components of a, b or c-classification
        if ((indexPath.row > 0) && (indexPath.row <4)) {
            
            //set the title of the classification
            NSString *classification = @"";
            switch (indexPath.row) {
                case 1:
                    classification = @"A - Components";
                    break;
                case 2:
                    classification = @"B - Components";
                    break;
                case 3:
                    classification = @"C - Components";
                    break;
                    
                default:
                    break;
            }
            
            [self.resultScreen showClassification:classification];
            
            
        }
        
        
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
    
    
    if ([self.state isEqualToString:@"projects"]) {
        NSArray *cell;
        for (cell in self.availableCells)
        {
            NSComparisonResult result = [[cell objectAtIndex:1] compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchText.length)];
            if (result == NSOrderedSame) {
                [output addObject:cell];
            }
        }
    } else if ([self.state isEqualToString:@"components"]) {
        Component *cell;
        for (cell in self.availableCells)
        {
            NSComparisonResult result = [cell.name compare:searchText options:NSCaseInsensitiveSearch range:NSMakeRange(0, searchText.length)];
            if (result == NSOrderedSame) {
                [output addObject:cell];
            }
        }
    } else if ([self.state isEqualToString:@"results"]) {
        //nothing -- search bar hidden
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









@end
