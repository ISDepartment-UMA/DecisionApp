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

@property (strong, nonatomic) IBOutlet UILabel *textLabelA;
@property (strong, nonatomic) IBOutlet UILabel *textLabelB;
@property (strong, nonatomic) IBOutlet UILabel *textLabelC;


//classification model
@property (strong, nonatomic) ClassificationModel *resultModel;
@end

@implementation ChartViewController
@synthesize textLabelA = _textLabelA;
@synthesize textLabelB = _textLabelB;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize textLabelC = _textLabelC;
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
    [self setTextLabelA:nil];
    [self setTextLabelB:nil];
    [self setTextLabelC:nil];
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
    
    
    CGRect frame = CGRectMake(0, 0, 703, 501);
    BNPieChart *chart = [[BNPieChart alloc] initWithFrame:frame];
    chart.backgroundColor = [UIColor whiteColor];
    int index = 0;
    
    for (int i=0; i<[componentClassification count]; i++) {
        
        double numberInThisCategory = 0.0;
        NSString *category;

        
        if ((numberInThisCategory = [[componentClassification objectAtIndex:i] count]) > 0) {
            
            if (i == 0) {
                category = @"A - In-House";
                if (self.textLabelA.hidden = YES) {
                    [self.textLabelA setHidden:NO];
                    self.textLabelA.textColor = [self getRGBForIndex:index];
                    index++;
                }
            } else if (i == 1) {
                category = @"B - Indifferent";
                if (self.textLabelB.hidden = YES) {
                    [self.textLabelB setHidden:NO];
                    self.textLabelB.textColor = [self getRGBForIndex:index];
                    index++;
                }
            } else {
                category = @"C - Likely Outsourced";
                if (self.textLabelC.hidden = YES) {
                    [self.textLabelC setHidden:NO];
                    self.textLabelC.textColor = [self getRGBForIndex:index];
                    index++;
                }
            }
            [chart addSlicePortion:(numberInThisCategory/totalComponents) withName:category];
        }
    }
    
    
    
    [self.view addSubview:chart];
    
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
