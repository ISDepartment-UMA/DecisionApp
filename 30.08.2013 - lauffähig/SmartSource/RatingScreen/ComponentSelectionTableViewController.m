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

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation ComponentSelectionTableViewController
@synthesize availableCells = _availableCells;
@synthesize ratingScreen = _ratingScreen;
@synthesize tableView = _tableView;
@synthesize selectedIndexPath = _selectedIndexPath;



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
    
    //select first component
    /*
    if (!self.selectedCell) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:nil];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
        self.selectedCell = cell;
    }*/
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"started cell for row at index path");
    static NSString *CellIdentifier = @"componentCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (cell) {
        NSLog(@"got cell");
        NSLog(NSStringFromClass([cell class]));
    }
    
    //disable selection style
    for (id sub in cell.subviews) {
        NSLog(NSStringFromClass([sub class]));
    }
    //get label
    UIView *contentView = [cell viewWithTag:20];
    if (contentView) {
        NSLog(@"got contentview");
    }
    id textLabel = [contentView viewWithTag:10];
    NSLog(NSStringFromClass([textLabel class]));
    
    
    Component *acutalComponent = [self.availableCells objectAtIndex:indexPath.row];
    [cell.textLabel setText:acutalComponent.name];
    [cell.textLabel setFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:15.0]];
    //[textLabel setText:acutalComponent.name];
    
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
    //change color of previously selected cell and selected cell
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [selectedCell.contentView setBackgroundColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.53 alpha:1.0]];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
    self.selectedIndexPath = indexPath;
    
    //set component
    [self.ratingScreen setComponent:[self.availableCells objectAtIndex:indexPath.row]];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
