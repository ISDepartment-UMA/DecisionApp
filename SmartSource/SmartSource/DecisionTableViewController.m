//
//  ResultTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DecisionTableViewController.h"
#import "Project.h"
#import "Component.h"
#import "SuperCharacteristic.h"
#import "Characteristic.h"
#import "SmartSourceSplitViewController.h"

@interface DecisionTableViewController ()
@property (strong, nonatomic) NSArray *columns;
@end

@implementation DecisionTableViewController
@synthesize columns = _columns;
@synthesize resultModel = _resultModel;


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
    [super viewDidUnload];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.splitViewController setDelegate:self];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Detailed Information about the A, B, C Categories:";
    self.columns = [self.resultModel getColumnsForDecisionTable];
    
    //check if barbuttonitem needs to be presented
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    if (splitViewController.masterPopoverController) {
        [self splitViewController:splitViewController willHideViewController:nil withBarButtonItem:splitViewController.barButtonItem forPopoverController:splitViewController.masterPopoverController];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"ABC Analysis";
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[[self.columns objectAtIndex:0] objectAtIndex:2] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //build cell
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"];
    for (int i=0; i< [self.columns count]; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20 + (i*71), 0, 61, 43)];
        [label setTag:(i+1)];
        [cell.contentView addSubview:label];
    }
    
    
    //top line of the table
    if (indexPath.row == 0) {
        for (int i=0; i<[self.columns count]; i++) {
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:(i+1)];
            label.text = [[self.columns objectAtIndex:i] objectAtIndex:0];
            [label setTextAlignment:UITextAlignmentLeft];
            [label setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
            float originX;
            if (i == 0) {
                originX = 10;
            } else {
                originX = 20+ 71*i;
            }
            [label setFrame:CGRectMake(originX, 0, 61, 240)];
            
        }
        
        //all other lines
    } else {
        for (int i=0; i < ([self.columns count]-1); i++) {
            UILabel *label = (UILabel *)[cell.contentView viewWithTag:(i+1)];
            
            //combination of possible ratings
            int rating = [[[[self.columns objectAtIndex:i] objectAtIndex:2] objectAtIndex:(indexPath.row-1)] intValue];
            
            switch (rating) {
                case 1:
                    label.text = @"Low";
                    label.textColor = [self getRGBForIndex:2];
                    break;
                case 2:
                    label.text = @"Medium";
                    label.textColor = [self getRGBForIndex:1];
                    
                    break;
                case 3:
                    label.text = @"High";
                    label.textColor = [self getRGBForIndex:0];
                default:
                    break;
            }
        }
        
        //
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:[self.columns count]];
        label.text = [[[self.columns lastObject] objectAtIndex:2] objectAtIndex:(indexPath.row-1)];
        if ([label.text isEqualToString:@"A"]) {
            [label setTextColor:[self getRGBForIndex:0]];
        } else if ([label.text isEqualToString:@"B"]) {
            [label setTextColor:[self getRGBForIndex:1]];
        } else if ([label.text isEqualToString:@"C"]) {
            [label setTextColor:[self getRGBForIndex:2]];
        }
        [label setTextAlignment:UITextAlignmentCenter];
        
    }
    
    
    // Configure the cell...
    
    return cell;
    
}


//builds the same color as used in the chart
//index: -0 for Component A -1 for Component B -2 for Component c
- (UIColor *)getRGBForIndex:(int)index {
    
    //switch index 1 and 2 to make first color red and second orange --> A components red
    //i know, bad implementation :-/
    if (index == 0) {
        index = 1;
    } else if (index == 1) {
        index = 0;
    }
    
    int i = 6 - index;
    float red = 0.5 + 0.5 * cos(i);
	float green = 0.5 + 0.5 * sin(i);
    float blue = 0.5 + 0.5 * cos(1.5 * i + M_PI / 4.0);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
	
}

//RootViewController.m
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 250;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
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
