//
//  RatingTableViewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingTableViewViewController.h"
#import "SmartSourceMasterViewController.h"
#import "Slider.h"
#import "UIKit/UIKit.h"
#import "SBJson.h"
#import "AvailableSuperCharacteristic.h"
#import "AvailableCharacteristic.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "DecisionTableViewController.h"
#import "ShowClassificationTableViewController.h"
#import "Project+Factory.h"
#import "ChartViewController.h"
#import "ComponentModel.h"
#import "CharacteristicCell.h"
#import "ProjectModel.h"
#import "SmartSourceAppDelegate.h"


@interface RatingTableViewViewController ()

//array of necessary rating characteristics 
@property (strong, nonatomic) NSArray *Characteristics;
//split view
//available components and current component+project
@property (strong, nonatomic) NSArray *availableComponents;
@property (strong, nonatomic) ComponentModel *currentComponent;
@property (strong, nonatomic) ProjectModel *currentProject;



@end

@implementation RatingTableViewViewController
@synthesize currentComponent = _currentComponent;
@synthesize Characteristics = _Characteristics;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize currentProject = _currentProject;
@synthesize availableComponents = _availableComponents;
@synthesize indexOfDisplayedComponent = _indexOfDisplayedComponent;



//methods to implement:

//check for completeness

- (void)checkForCompleteness
{
    if ([self.currentProject ratingIsComplete]) {
        
        //build button to put it up right
        self.navigationItem.title = @"Rating is complete";
        UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithTitle:@"View Results" style:UIBarButtonItemStyleBordered target:self action:@selector(showRating)];
        [self.navigationItem setRightBarButtonItem:barbutton];
    }
}

- (void)saveContext
{
    if (![self.currentComponent saveContext]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)showRating
{
    //show at a glance overview in detail screen
    [self performSegueWithIdentifier:@"atAGlance" sender:self];
}



//sets the component currently displayed in the ratingtableview
- (void)setComponent:(NSInteger)component
{
    //initialize model for component
    self.currentComponent = [[ComponentModel alloc] initWithComponent:[self.availableComponents objectAtIndex:component]];
    
    //check for completeness
    [self checkForCompleteness];
    
    //get rating characteristics
    self.Characteristics = [self.currentComponent getCharacteristics];

    
    [self.tableView reloadData];
    
    //if component has been selected, dismiss popovercontroller
    [self.masterPopoverController dismissPopoverAnimated:YES];
    self.indexOfDisplayedComponent = component;
    
    
    
    

}




//method to set the project, the components should be retrieved from
- (void)setProject:(NSString *)projectID
{
    
    self.currentProject = [[ProjectModel alloc] initWithProjectID:projectID];

    self.availableComponents = [self.currentProject arrayWithComponents];
    
    [self setComponent:0];
    
    //Notification to reload masterview
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadComponentsIntoMasterView" object:self];
    
    //hide back button
    self.navigationItem.hidesBackButton = YES;
    
}


- (NSArray *)getAvailableComponents
{
    return self.availableComponents;
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationItem setLeftBarButtonItem:nil];
}

- (void)backToProjects
{
    [self.navigationItem setLeftBarButtonItem:nil];
    [self.navigationItem setLeftBarButtonItems:nil];
    DetailTableViewController *detail = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:detail animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsIntoMasterView" object:detail];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MasterViewGet" object:self];
    //self.navigationController.navigationBarHidden = YES;

}



- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Components", @"Components");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:self.navigationItem.leftBarButtonItem, barButtonItem];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    //self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:self.navigationItem.leftBarButtonItem, barButtonItem];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of supercharacteristics +1 section for component info
    if ([self.availableComponents count] > 0) {
        return 1 + [[self.Characteristics objectAtIndex:0] count];
    } else {
        return 0;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{


    //return number of characteristics that belong to the supercharacteristic
    if (section < [[self.Characteristics  objectAtIndex:0] count]) {
        return 1+ [[[self.Characteristics objectAtIndex:1] objectAtIndex:section] count];
        
    //or return 7 for the component info section
    } else {
        return 7;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //the first row of each section should present a supercharacteristik with a slider to weight it
    if (indexPath.section < [[self.Characteristics objectAtIndex:1] count]) {
        
        
        if (indexPath.row == 0) {
            
            SuperCharacteristic *superChar = [[self.Characteristics objectAtIndex:0] objectAtIndex:indexPath.section];
            //return cell of supercharacteristic with weight-slider
            //get cell
            static NSString *CellIdentifier = @"superCharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //set label
            UILabel *text = (UILabel *)[cell viewWithTag:10];
            text.text = superChar.name;
            
            //add action to slider
            Slider *slider = (Slider *)[cell viewWithTag:11];
            
            //set the sliders rating controller to self in order for it to be able to talk back to us and save its value
            [slider setSliderDelegate:self];
            
            
            //slider value according to stored value in core database
            slider.value = [superChar.weight floatValue];
            
            return cell;
            
        } else {
            
            //return cell of subcharacteristic
            //get characteristic
            Characteristic *rightCharacteristic = [[[self.Characteristics objectAtIndex:1] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
            
            //return cell with characteristic
            return [[CharacteristicCell alloc] initWithCharacteristic:rightCharacteristic andDelegate:self];
            
        }
    } else{
        
        //info about component
        static NSString *CellIdentifier = @"componentInfoCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return [self makeComponentInfoCell:cell forRow:indexPath.row];
    }

    

}
 

//modifies cells to present info about current component on it
- (UITableViewCell *)makeComponentInfoCell:(UITableViewCell *)cell forRow:(int)row
 {
     NSArray *componentInfo = [NSArray arrayWithObjects:@"ComponentInfo", @"ID", @"Name", @"Description", @"Priority", @"Estimated Hours", @"Modifier", nil];
     NSArray *info = [self.currentComponent getComponentInfo];
     cell.textLabel.text = [componentInfo objectAtIndex:row];
     if (row > 0) {
          cell.detailTextLabel.text = [info objectAtIndex:(row)];
     }
    
     return cell;
 }


//save weight from slider into model
- (void)saveValueForSlider:(Slider *)slider
{
    //get name of supercharacteristic
    UILabel *textLabel = (UILabel *)[slider.superview viewWithTag:10];
    
    //save weight into model
    [self.currentComponent saveWeight:[NSNumber numberWithFloat:slider.value] forSuperCharacteristic:textLabel.text];
}







//RootViewController.m
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //empty
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //segue to results screen
    if ([segue.identifier isEqualToString:@"atAGlance"]) {
        
        //pass project id to results screen
        ChartViewController *resOVC = segue.destinationViewController;
        [resOVC initializeClassificationForProject:[self.currentProject getID]];
        
        //pass barbuttonitem that hides popover controller to result screen
        if([self.navigationItem.leftBarButtonItems count] > 0) {
            UIBarButtonItem *barButtonItem = [self.navigationItem.leftBarButtonItems objectAtIndex:0];
            barButtonItem.title = NSLocalizedString(@"Result Overview", @"Result Overview");
            resOVC.navigationItem.leftBarButtonItem = barButtonItem;
            resOVC.masterPopoverController = self.masterPopoverController;
            
        }
       
    }
}


@end
