//
//  ResultMaserViewController.m
//  SmartSource
//
//  Created by Lorenz on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ResultMasterViewController.h"
#import "Project.h"
#import "Component.h"
#import "SuperCharacteristic.h"
#import "Characteristic.h"
#import "DecisionTableViewController.h"
#import "ShowClassificationTableViewController.h"
#import "RatingTableViewViewController.h"
#import "DetailTableViewController.h"
#import "ChartViewController.h"

@interface ResultMasterViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSArray *componentClassification;
@property (strong, nonatomic) NSArray *availableCells;
@property (strong, nonatomic) NSString *currentProject;
@property (strong, nonatomic) ChartViewController *resultScreen;

@end

@implementation ResultMasterViewController
@synthesize currentProjectTitle = _currentProjectTitle;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize componentClassification = _componentClassification;
@synthesize availableCells = _availableCells;
@synthesize currentProject = _currentProject;
@synthesize resultScreen = _resultScreen;



- (NSArray *)availableCells
{
    if (!_availableCells) {
        _availableCells = [NSArray arrayWithObjects:@"At One Glance", @"A Classified", @"B Classified", @"C Classified", @"Detailed Decision Table" ,nil];
        return _availableCells;
        
    } else {
        return _availableCells;
    }
}


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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //select first row
    [self.resultScreen createViewForProject:self.componentClassification];
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (void)prepareResultsForProject:(NSString *)projectID
{
    self.currentProject = projectID;
    //get Project details from core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    request.predicate = [NSPredicate predicateWithFormat:@"projectID =%@", projectID];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    Project *project = [matches lastObject];
    
    //get project
    self.currentProjectTitle = project.name;
    NSEnumerator *componentEnumerator = [project.consistsOf objectEnumerator];
    
    //iterate through components
    NSArray *classification = [NSArray arrayWithObjects:[NSMutableArray array], [NSMutableArray array], [NSMutableArray array], nil];
    Component *comp;
    while ((comp = [componentEnumerator nextObject]) != nil) {
        
        
        //initiate array for rating values of supercharacteristics
        NSMutableArray *ratingValuesSuperChar = [NSMutableArray array];
        
        
        //iterate through all SuperCharacteristics to get their weighted rating value and add up the total weight of all supercharacteristics
        double totalWeight = 0.0;
        SuperCharacteristic *superChar;
        NSEnumerator *superCharEnumerator = [comp.ratedBy objectEnumerator];
        while ((superChar = [superCharEnumerator nextObject]) != nil) {
            
            //initiate rating value for supercharacteristic
            double valueOfSuperCharacteristic = 0.0;
            
            //iterate through all characteristics and add their values to the value of supercharacteristic
            Characteristic *characteristic;
            NSEnumerator *charEnumerator = [superChar.superCharacteristicOf objectEnumerator];
            while ((characteristic = [charEnumerator nextObject]) != nil) {
                valueOfSuperCharacteristic = valueOfSuperCharacteristic + [characteristic.value doubleValue];
            }
            
            //divide by number of characteristics --> average
            double numberOfCharacteristics = [[superChar superCharacteristicOf] count];
            valueOfSuperCharacteristic = (valueOfSuperCharacteristic/numberOfCharacteristics);
            
            
            //add weight to total weight of all supercharacteristics
            totalWeight = totalWeight + [superChar.weight doubleValue];
            
            //add weighted value to array
            double weightedValueofSuperCharacteristic = valueOfSuperCharacteristic * [superChar.weight doubleValue];
            [ratingValuesSuperChar addObject:[NSNumber numberWithDouble:weightedValueofSuperCharacteristic]];
            
        }
        
        //build weighted average of the rating of ONE component
        NSArray *ratingValues = [ratingValuesSuperChar copy];
        double sum = 0.0;
        for (int i=0; i<[ratingValues count]; i++) {
            sum = sum + [[ratingValues objectAtIndex:i] doubleValue];
        }
        
        //calculate component weighted value
        double componentWeightedValue = (sum/totalWeight);
        
        //put component info into ABC-Classification according to its component weighted value
        // A <=> objectAtIndex 0, B <=> objectAtIndex 1, C <=> objectAtIndex 2
        if (componentWeightedValue < 1.67) {
            [[classification objectAtIndex:2] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        } else if (componentWeightedValue < 2.34) {
            [[classification objectAtIndex:1] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        } else if (componentWeightedValue <= 3.0) {
            [[classification objectAtIndex:0] addObject:[NSArray arrayWithObjects:comp.id, comp.name, [NSNumber numberWithDouble:componentWeightedValue], nil]];
        }
    }

    self.componentClassification = classification;

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
    return [self.availableCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"resultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    cell.textLabel.text = [self.availableCells objectAtIndex:indexPath.row];
    
    if ((indexPath.row >0) && (indexPath.row <4)) {
        int number = [[self.componentClassification objectAtIndex:(indexPath.row-1)] count];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", number];
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.resultScreen.navigationController popToViewController:self.resultScreen animated:NO];
    
    //if user wants to see the decision talbe
    if (indexPath.row ==4) {
        
        [self.resultScreen performSegueWithIdentifier:@"decisionTable" sender:self];
        DecisionTableViewController *decVC = (DecisionTableViewController *)self.resultScreen.navigationController.visibleViewController;
        [decVC createRatingTable:self.currentProject];
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
        

            
        [self.resultScreen performSegueWithIdentifier:@"showClassification" sender:self];
        ShowClassificationTableViewController *show = (ShowClassificationTableViewController *)[self.resultScreen.navigationController visibleViewController];
            
        //set the detailed screen with title and ccomponents
        [show setDisplayedClassification:classification withComponents:[self.componentClassification objectAtIndex:(indexPath.row-1)]];
    }
    

        

}

@end
