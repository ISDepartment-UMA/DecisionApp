//
//  ShowClassificationTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShowClassificationTableViewController.h"
#import "ComponentDetailInfoViewController.h"
#import "ClassificationModel.h"
#import "SmartSourceSplitViewController.h"

@interface ShowClassificationTableViewController ()

@property (strong, nonatomic) NSArray *availableCells;
@property (strong, nonatomic) ClassificationModel *resultModel;

@end

@implementation ShowClassificationTableViewController
@synthesize availableCells = _availableCells;
@synthesize resultModel = _resultModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setDisplayedClassification:(NSString *)classification fromModel:(ClassificationModel *)model
{
    self.navigationItem.hidesBackButton = YES;
    self.resultModel = model;
    self.availableCells = [model getComponentsForCategory:classification];
    self.title = classification;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.splitViewController setDelegate:self];
    //check if barbuttonitem needs to be presented
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    if (splitViewController.masterPopoverController) {
        [self splitViewController:splitViewController willHideViewController:nil withBarButtonItem:splitViewController.barButtonItem forPopoverController:splitViewController.masterPopoverController];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];



}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.navigationItem.prompt = nil;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Results Overview", @"Results Overview");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //store popoverController and barButtonItem in splitview to make it available for previous/later view controllers
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    [splitViewController setMasterPopoverController:popoverController];
    [splitViewController setBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //reset the splitviewcontroller's properties to nil
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    [splitViewController setMasterPopoverController:nil];
    [splitViewController setBarButtonItem:nil];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.navigationItem.prompt;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.availableCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [[self.availableCells objectAtIndex:indexPath.row] objectAtIndex:1];
    // Configure the cell...
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showComponentDetail" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    
    //segue to component detail info view
    if ([segue.identifier isEqualToString:@"showComponentDetail"]) {
        
        //hand over model and component
        ComponentDetailInfoViewController *cdivc = (ComponentDetailInfoViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [cdivc setComponent:[[self.availableCells objectAtIndex:indexPath.row] objectAtIndex:0] andModel:self.resultModel];

        
    }
}

@end
