//
//  ComponentSelectionTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 12.07.13.
//
//

#import "ComponentSelectionTableViewController.h"
#import "ProjectModel.h"
#import "RatingTableViewViewController.h"
#import "VeraRomanLabel.h"

@interface ComponentSelectionTableViewController ()
@property (nonatomic, strong) NSArray *availableCells;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) RatingTableViewViewController *ratingScreen;
@property (strong, nonatomic) IBOutlet UILabel *componentRatingCompleteLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightingCompleteLabel;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation ComponentSelectionTableViewController
@synthesize availableCells = _availableCells;
@synthesize ratingScreen = _ratingScreen;
@synthesize tableView = _tableView;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize componentRatingCompleteLabel = _componentRatingCompleteLabel;
@synthesize weightingCompleteLabel = _weightingCompleteLabel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //check for components on the detail side
    self.ratingScreen = nil;
    while (!self.ratingScreen) {
        UINavigationController *detailNavigation = [self.splitViewController.viewControllers lastObject];
        id visibleViewController = detailNavigation.visibleViewController;
        if ([visibleViewController isKindOfClass:[RatingTableViewViewController class]]) {
            self.ratingScreen = visibleViewController;
            [self.ratingScreen masterViewIsThere];
        }
    }
    
    
    //get components and selected index path
    self.availableCells = [self.ratingScreen getAvailableComponents];
    Component *selectedComponent = [self.ratingScreen getSelectedComponent];
    for (int i=0; i < [self.availableCells count]; i++) {
        Component *comp = [self.availableCells objectAtIndex:i];
        if ([comp.componentID isEqualToString:selectedComponent.componentID]) {
            self.selectedIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
        }
    }
    
    //reload table
    [self.tableView reloadData];
    
    if (self.selectedIndexPath) {
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    } else {
        self.selectedIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    }
    
    //check for completeness
    if (self.ratingScreen.componentRatingIsComplete) {
        [self.componentRatingCompleteLabel setText:@"\u2713"];
    } else {
        [self.componentRatingCompleteLabel setText:@""];
    }
    
    if (self.ratingScreen.weightingIsComplete) {
        [self.weightingCompleteLabel setText:@"\u2713"];
    } else {
        [self.weightingCompleteLabel setText:@""];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.ratingScreen masterViewIsNotThere];
    [super viewWillDisappear:animated];
}


- (IBAction)weightingButtonPressed:(id)sender {
    [self.ratingScreen setWeightingIsComplete:YES];
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        NSLog(@"portrait");
        [self dismissViewControllerAnimated:YES completion:^{
            [self.splitViewController performSegueWithIdentifier:@"weightSuperChars" sender:self];
        }];
    } else {
        [self.splitViewController performSegueWithIdentifier:@"weightSuperChars" sender:self];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)reloadTableView
{
    //reload table view
    [self.tableView reloadData];
    
    //check for completeness
    if (self.ratingScreen.componentRatingIsComplete) {
        [self.componentRatingCompleteLabel setText:@"\u2713"];
    } else {
        [self.componentRatingCompleteLabel setText:@""];
    }
    
    if (self.ratingScreen.weightingIsComplete) {
        [self.weightingCompleteLabel setText:@"\u2713"];
    } else {
        [self.weightingCompleteLabel setText:@""];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.availableCells) {
        if ([self.availableCells count] > 0) {
            return 1;
        } else {
            return 0;
        }
    } else {
            return 0;
    
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.availableCells count];
}


//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"componentSelectionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //disable selection style
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Component *acutalComponent = [self.availableCells objectAtIndex:indexPath.row];
    UIView *contentView = [cell viewWithTag:120];
    [((UILabel *)[cell viewWithTag:121]) setText:acutalComponent.name];
    
    if ([acutalComponent.ratingComplete boolValue]) {
        [((UILabel *)[cell viewWithTag:122]) setText:@"\u2713"];
    } else {
        [((UILabel *)[cell viewWithTag:122]) setText:@""];
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        [contentView setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    } else {
        [contentView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //change color of previously selected cell and selected cell
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [((UILabel *)[selectedCell viewWithTag:120]) setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [((UILabel *)[cell viewWithTag:120]) setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    self.selectedIndexPath = indexPath;
    
    //set component
    [self.ratingScreen setComponent:[self.availableCells objectAtIndex:indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setComponentRatingCompleteLabel:nil];
    [self setWeightingCompleteLabel:nil];
    [super viewDidUnload];
}
@end
