//
//  RatedProjectTableViewController.m
//  SmartSourcer
//
//  Created by Lorenz on 18.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatedProjectTableViewController.h"

@interface RatedProjectTableViewController ()
@property (nonatomic, strong)NSArray *availableCells;
@property (strong, nonatomic) NSArray *displayedCells;  //cells that are displayed in the tableview
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation RatedProjectTableViewController
@synthesize searchBar = _searchBar;
@synthesize availableCells = _availableCells;
@synthesize displayedCells = _displayedCells;

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
    
    //todo hier muss die interne datenbank eingebunden werden
    self.availableCells = [NSArray arrayWithObjects:@"Lorenz", @"TOmmi", nil];
    self.displayedCells = self.availableCells;
    self.searchBar.delegate = self;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.displayedCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Project Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = [self.displayedCells objectAtIndex:indexPath.row];
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

//Handling SearchBarQuery

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
    for (NSString *cell in self.availableCells) {
        @autoreleasepool {
            NSRange r = [cell rangeOfString:searchText];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
