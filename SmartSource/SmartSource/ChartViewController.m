//
//  ChartViewController.m
//  SmartSource
//
//  Created by Lorenz on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChartViewController.h"
#import "BNPieChart.h"
#import "Project.h"
#import "Component.h"
#import "DecisionTableViewController.h"
#import "ShowClassificationTableViewController.h"
#import "BNColor.h"
#import "ClassificationModel.h"
#import "SmartSourceAppDelegate.h"

@interface ChartViewController ()


//classification model
@property (strong, nonatomic) ClassificationModel *resultModel;
@end

@implementation ChartViewController
@synthesize masterPopoverController = _masterPopoverController;
@synthesize resultModel = _resultModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//returns classification from model
- (NSArray *)getClassificationForCurrentProject
{
    return self.resultModel.classification;
}

- (void)showDecisionTable
{
    //if decision table has been selected, dismiss popovercontroller
    [self.masterPopoverController dismissPopoverAnimated:YES];
    //perform segue
    [self performSegueWithIdentifier:@"decisionTable" sender:self];
}

- (void)showClassification:(NSString *)classification
{
    //if classification has been selected, dismiss popovercontroller
    [self.masterPopoverController dismissPopoverAnimated:YES];
    [self performSegueWithIdentifier:@"showClassification" sender:classification];
    
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
    //if decision table has been selected, dismiss popovercontroller
    [self.masterPopoverController dismissPopoverAnimated:YES];
    
}



- (void)viewDidUnload
{
    self.navigationController.navigationBarHidden = YES;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.splitViewController setDelegate:self];
    [self.navigationItem setHidesBackButton:YES];

}

- (void)initializeClassificationForProject:(NSString *)projectID
{    
    //initialize model
    self.resultModel = [[ClassificationModel alloc] initWithProjectID:projectID];
    
    //build result chart from model
    [self createViewForClassification:self.resultModel.classification];
    
    //set title in navigation bar
    self.navigationItem.title = [[@"Component Classification for " stringByAppendingString:[self.resultModel getProjectName]] stringByAppendingString:@":"];
    
    
}




//method called to display chart
//passed parameter is a 2-dimensional array of classifications
//index 0 <-> AClassified Components, index 1 -B, index 2 - C
//2nd dimension - components
- (void)createViewForClassification:(NSArray *)componentClassification
{
    
    double totalComponents = 0.0;
    for (int i=0; i<[componentClassification count]; i++) {
        totalComponents = totalComponents + [[componentClassification objectAtIndex:i] count];
    }
    
    //initialize chart
    CGRect frame = CGRectMake(0, 0, 703, 501);
    BNPieChart *chart = [[BNPieChart alloc] initWithFrame:frame];
    chart.backgroundColor = [UIColor whiteColor];
    int index = 0;
   
    //create text label for A - component description
    UILabel *textLabelA = [[UILabel alloc] initWithFrame:CGRectMake(20, 520, 663, 42)];
    [textLabelA setTextColor:[self getRGBForIndex:0]];
    [textLabelA setText:@"A - Core Component: Likely to be kept in-house."];
    [textLabelA setFont:[UIFont fontWithName:@"System" size:17.0]];
    [self.view addSubview:textLabelA];
    
    //create text label for B - component description
    UILabel *textLabelB = [[UILabel alloc] initWithFrame:CGRectMake(20, 570, 663, 42)];
    [textLabelB setTextColor:[self getRGBForIndex:1]];
    [textLabelB setText:@"B - Sourcing location indifferent: In-house preferred but outsourcing possible."];
    [textLabelB setFont:[UIFont fontWithName:@"System" size:17.0]];
    [self.view addSubview:textLabelB];
    
    //create text label for C - component description
    UILabel *textLabelC = [[UILabel alloc] initWithFrame:CGRectMake(20, 620, 663, 42)];
    [textLabelC setTextColor:[self getRGBForIndex:2]];
    [textLabelC setText:@"C - Component most likely to be outsourced."];
    [textLabelC setFont:[UIFont fontWithName:@"System" size:17.0]];
    [self.view addSubview:textLabelC];
    
    
    //add slices for classifications with text labels to chart
    for (int i=0; i<[componentClassification count]; i++) {
        
        double numberInThisCategory = 0.0;
        NSString *category = @" ";
        
        if ((numberInThisCategory = [[componentClassification objectAtIndex:i] count]) > 0) {
            
            if (i == 0) {
                category = @"A - In-House";
        
            } else if (i == 1) {
                category = @"B - Indifferent";
                
            } else {
                category = @"C - Likely Outsourced";
                
            }
        }
        [chart addSlicePortion:(numberInThisCategory/totalComponents) withName:category];
        [self.view setNeedsDisplay];
        
        
    }
    
    
    
    [self.view addSubview:chart];
    
}

//builds the same color as used in the chart
//index: -0 for Component A -1 for Component B -2 for Component c
- (UIColor *)getRGBForIndex:(int)index {
    float red, green, blue;
    
    if (index == 0) {
        //red
        red = (0.6);//0.5 + 0.5 * cos(5);
        green = (0);//0.5 + 0.5 * sin(5);
        blue = (0); //0.5 + 0.5 * cos(1.5 * 5.0 + M_PI / 4.0);
        
    } else if (index == 1) {
        //orange
        red = 1;//0.5 + 0.5 * cos(-7);
        green = 0.5; // + 0.5 * sin(-7);
        blue = 0; //0.5 + 0.5 * cos(1.5 * (-7) + M_PI / 4.0);
        /*
        red = 0.5 + 0.5 * cos(-7);
        green = 0.5 + 0.5 * sin(-7);
        blue = 0.5 + 0.5 * cos(1.5 * (-7) + M_PI / 4.0);*/
        
    } else if (index == 2) {
        //green
        red = 0.5 + 0.5 * cos(-3);
        green = 0.5 + 0.5 * sin(-3);
        blue = 0.5 + 0.5 * cos(1.5 * (-3.0) + M_PI / 4.0);
    } else {
        return nil;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Result Overview", @"Result Overview");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //segue to decision table
    if ([segue.identifier isEqualToString:@"decisionTable"]) {
        
        //pass result model
        DecisionTableViewController *decTVC = segue.destinationViewController;
        decTVC.resultModel = self.resultModel;
        
        //pass barbuttonitem that hides popover controller to rating screen
        if(self.navigationItem.leftBarButtonItem != nil) {
            decTVC.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
            decTVC.masterPopoverController = self.masterPopoverController;
        }
    }
    
    //segue to classification
    if ([segue.identifier isEqualToString:@"showClassification"]) {
        
        //pass result model
        ShowClassificationTableViewController *scTVC = segue.destinationViewController;
        [scTVC setDisplayedClassification:sender fromModel:self.resultModel];
        
        //pass barbuttonitem that hides popover controller to rating screen
        if(self.navigationItem.leftBarButtonItem != nil) {
            scTVC.navigationItem.leftBarButtonItem = self.navigationItem.leftBarButtonItem;
            scTVC.masterPopoverController = self.masterPopoverController;
        }
    }
}

@end
