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

@interface DecisionTableViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *columns;
@end

@implementation DecisionTableViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize columns = _columns;


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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//creates a table featuring all possible combinations of characteristics ratings and their result for the classification
- (void)createRatingTable:(NSString *)projectID
{
    //get Project details from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    Project *project = [matches lastObject];
    Component *oneComponent = [project.consistsOf objectEnumerator].nextObject;
    
    //initiate coulmn array
    NSMutableArray *columns = [NSMutableArray array];
    double characteristicNumber = 0;
    double numberOfCombinations = pow(3, [oneComponent.ratedBy count]);
    
    //iterate through supercharacteristics
    SuperCharacteristic *currentSuperchar;
    NSEnumerator *superCharEnumerator = [oneComponent.ratedBy objectEnumerator];
    while ((currentSuperchar = [superCharEnumerator nextObject]) != nil) {
        
        //prepare array with all possible ratings of available characteristics
        NSMutableArray *tmp = [NSMutableArray array];
        
        while ([[tmp copy] count] <= numberOfCombinations) {
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:1]];
                }
            }
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:2]];
                }
            }
            for (int i=0; i<pow(3.0, characteristicNumber); i++) {
                if ([[tmp copy] count] <= numberOfCombinations) {
                    [tmp addObject:[NSNumber numberWithInt:3]];
                }
            }
        }
        [columns addObject:[NSArray arrayWithObjects:currentSuperchar.name, currentSuperchar.weight, [tmp copy], nil]];
        characteristicNumber++;
        
    }
    
    //build the weighted average of all supercharacteristics and determine its ABC status
    //get the sum of all weights of supercharacteristics
    double sumWeight = 0;
    for (int i=0; i<[[columns copy] count]; i++) {
        sumWeight += [[[columns objectAtIndex:i] objectAtIndex:1] doubleValue];
    }
    
    //prepar rating array
     NSMutableArray *tmpWeightedValues = [NSMutableArray array];
    
    
    for (int i=0; i < [[[columns lastObject] objectAtIndex:2] count]; i++) {
        //get the sum of weighted ratings
        double sum = 0;
        for (int y=0; y<[columns count]; y++) {
            sum = sum + ([[[[columns objectAtIndex:y] objectAtIndex:2] objectAtIndex:i] intValue] * [[[columns objectAtIndex:y] objectAtIndex:1] intValue]);
        }
        
        //devide the sum of weighted ratings by the sum of weights
        double weightedValue = (sum/sumWeight);
        
        //--> weighted value
        if (weightedValue < 1.67) {
            [tmpWeightedValues addObject:@"C"];
        } else if (weightedValue < 2.34) {
            [tmpWeightedValues addObject:@"B"];
        } else if (weightedValue <= 3) {
            [tmpWeightedValues addObject:@"A"];
        }
        
            
        

    }
    
    NSArray *weightedValues = [NSArray arrayWithObjects:@"Weighted Value", @"", tmpWeightedValues, nil];
    [columns addObject:weightedValues];
    
    self.navigationController.navigationBarHidden = YES;
    self.columns = [columns copy];
    
    
    
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Justification", @"Justification");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
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
