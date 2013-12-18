//
//  RatingTableViewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingTableViewViewController.h"
#import "UIKit/UIKit.h"
#import "Slider.h"
#import "AvailableSuperCharacteristic.h"
#import "AvailableCharacteristic.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "DecisionTableViewController.h"
#import "Project+Factory.h"
#import "ComponentModel.h"
#import "CharacteristicCell.h"
#import "SmartSourceAppDelegate.h"
#import "SmartSourceSplitViewController.h"
#import "UIImageView+PermanentScroller.h"
#import "ComponentSelectionTableViewController.h"
#import "WeightSuperCharacteristicsViewController.h"
#import "ModalAlertViewController.h"
#import "SmartSourceFunctions.h"
#import "UIColor+SmartSourceColors.h"
#import "SodaCharacteristicCell.h"


@interface RatingTableViewViewController ()

@property (strong, nonatomic) ComponentModel *currentComponent;
@property (strong, nonatomic) ProjectModel *currentProject;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet UIView *buttonsViewBottom;
@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *screenTitleLabel;
//barbutton
@property (strong, nonatomic) IBOutlet UIView *barButtonBackGroundView;
@property (strong, nonatomic) IBOutlet UIButton *barButton;
//array of necessary rating characteristics 
@property (strong, nonatomic) NSArray *characteristics;
//available components and current component+project
@property (strong, nonatomic) NSArray *availableComponents;
//show full description of component
@property (nonatomic) BOOL tableViewShowsFullComponentDescription;
@property (nonatomic) CGFloat heightDescriptionLabel;
@property (nonatomic, strong) NSString *textDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *componentRatingCompleteLabel;
@property (strong, nonatomic) IBOutlet UILabel *weightingCompleteLabel;
@property (nonatomic) BOOL shouldReturnToMainMenuImmediately;
@end

@implementation RatingTableViewViewController
@synthesize currentComponent = _currentComponent;
@synthesize characteristics = _characteristics;
@synthesize currentProject = _currentProject;
@synthesize availableComponents = _availableComponents;
@synthesize displayedComponent = _displayedComponent;
@synthesize topBar = _topBar;
@synthesize barButton = _barButton;
@synthesize projectNameLabel = _projectNameLabel;
@synthesize barButtonBackGroundView = _barButtonBackGroundView;
@synthesize tableViewShowsFullComponentDescription = _tableViewShowsFullComponentDescription;
@synthesize heightDescriptionLabel = _heightDescriptionLabel;
@synthesize textDescriptionLabel = _textDescriptionLabel;
@synthesize buttonsViewBottom = _buttonsViewBottom;
@synthesize componentRatingCompleteLabel = _componentRatingCompleteLabel;
@synthesize weightingCompleteLabel = _weightingCompleteLabel;
@synthesize componentRatingIsComplete = _componentRatingIsComplete;
@synthesize weightingIsComplete = _weightingIsComplete;
@synthesize screenTitleLabel = _screenTitleLabel;
@synthesize shouldReturnToMainMenuImmediately = _shouldReturnToMainMenuImmediately;

//indices for SDOA characteristics --> necessary for automatic detection
static NSInteger indexOfCommunicationComplexity;
static NSInteger indexOfCohesionCell;
static NSInteger indexOfCouplingCell;



#pragma mark Inherited Methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.splitViewController.delegate = self;
    
    //check if barbuttonitem needs to be presented
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    if (splitViewController.masterPopoverController) {
        [self splitViewController:splitViewController willHideViewController:nil withBarButtonItem:splitViewController.barButtonItem forPopoverController:splitViewController.masterPopoverController];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView reloadData];
    //show main menu
    [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self];
    //set tag to show scrollers permenantly
    [self.tableView setTag:noDisableVerticalScrollTag];
    self.tableViewShowsFullComponentDescription = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //show scrollers once and they won't disappear
    [self.tableView flashScrollIndicators];
    
    //hide three dimensional borders of splitviewcontroller in ios6
    if (![SmartSourceFunctions deviceRunsiOS7]) {
        CGFloat yOriginOfBottomBar = self.view.frame.size.height - 40;
        UIView *bottommask = [[UIView alloc] initWithFrame:CGRectMake(315, yOriginOfBottomBar, 12, 40)];
        [bottommask setBounds:CGRectMake(315, yOriginOfBottomBar, 12, 40)];
        [bottommask setBackgroundColor:[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0f]];
        [[self.splitViewController view] insertSubview:bottommask atIndex:0];
        
        UIView *headerMask = [[UIView alloc] initWithFrame:CGRectMake(315, 0, 12, 45)];
        [headerMask setBounds:CGRectMake(315, 0, 12, 45)];
        [headerMask setBackgroundColor:[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0f]];
        [[self.splitViewController view] insertSubview:headerMask atIndex:0];
        
        UIView *centerMask = [[UIView alloc] initWithFrame:CGRectMake(315, 44, 12, (yOriginOfBottomBar - 44))];
        [centerMask setBounds:CGRectMake(315, 44, 12, (yOriginOfBottomBar - 44))];
        [centerMask setBackgroundColor:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0f]];
        [[self.splitViewController view] insertSubview:centerMask atIndex:0];
    } else {
        
        CGFloat xOriginOfDividerLine = 315;
        
        UIView *statusBarMask = [[UIView alloc] initWithFrame:CGRectMake(xOriginOfDividerLine, 0, 12, 20)];
        [statusBarMask setBounds:CGRectMake(xOriginOfDividerLine, 0, 12, 20)];
        [statusBarMask setBackgroundColor:[UIColor blackColor]];
        [[self.splitViewController view] insertSubview:statusBarMask atIndex:0];
        
        UIView *headerMask = [[UIView alloc] initWithFrame:CGRectMake(xOriginOfDividerLine, 20, 12, 45)];
        [headerMask setBounds:CGRectMake(xOriginOfDividerLine, 0, 12, 45)];
        [headerMask setBackgroundColor:[UIColor colorOrange]];
        [[self.splitViewController view] insertSubview:headerMask atIndex:0];
        
        CGFloat yOriginOfBottomBar = self.view.frame.size.height - 40;
        UIView *bottommask = [[UIView alloc] initWithFrame:CGRectMake(315, yOriginOfBottomBar, 12, 40)];
        [bottommask setBounds:CGRectMake(315, yOriginOfBottomBar, 12, 40)];
        [bottommask setBackgroundColor:[UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0f]];
        [[self.splitViewController view] insertSubview:bottommask atIndex:0];
        
        UIView *centerMask = [[UIView alloc] initWithFrame:CGRectMake(xOriginOfDividerLine, 65, 12, (yOriginOfBottomBar - 44))];
        [centerMask setBounds:CGRectMake(315, 65, 12, (yOriginOfBottomBar - 44))];
        [centerMask setBackgroundColor:[UIColor colorDarkGray]];
        [[self.splitViewController view] insertSubview:centerMask atIndex:0];
    }
    //in portrait mode center header
    UIInterfaceOrientation deviceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(deviceOrientation)) {
        [self masterViewIsNotThere];
    }
}


- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setTopBar:nil];
    [self setBarButton:nil];
    [self setProjectNameLabel:nil];
    [self setBarButtonBackGroundView:nil];
    [self setBarButton:nil];
    [self setBarButtonBackGroundView:nil];
    [self setButtonsViewBottom:nil];
    [self setComponentRatingCompleteLabel:nil];
    [self setWeightingCompleteLabel:nil];
    [self setScreenTitleLabel:nil];
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark Getters & Setters

//if componentratingcomplete is set, update view
- (void)setComponentRatingIsComplete:(BOOL)componentRatingIsComplete
{
    _componentRatingIsComplete = componentRatingIsComplete;
    if (componentRatingIsComplete) {
        [self.componentRatingCompleteLabel setText:@"\u2713"];
    } else {
        [self.componentRatingCompleteLabel setText:@""];
    }
}

//if weighting is complete set, update view
- (void)setWeightingIsComplete:(BOOL)weightingIsComplete
{
    _weightingIsComplete = weightingIsComplete;
    //set check mark on button in lower left corner
    if (weightingIsComplete) {
        [self.currentProject setProjectHasBeenWeightedTrue];
        [self.weightingCompleteLabel setText:@"\u2713"];
    } else {
        [self.weightingCompleteLabel setText:@""];
    }
}


//sets the component currently displayed in the ratingtableview
- (void)setComponent:(Component *)component
{
    self.tableViewShowsFullComponentDescription = NO;
    //initialize model for component
    self.currentComponent = [[ComponentModel alloc] initWithComponentId:component.componentID];
    //get rating characteristics
    self.characteristics = [self.currentComponent getCharacteristics];
    //soda - get indices
    [self getIndicesForCommunicationComplexity];
    [self.tableView reloadData];
    //if component has been selected, dismiss popovercontroller
    SmartSourceSplitViewController *splitVC = (SmartSourceSplitViewController *)self.splitViewController;
    [splitVC.masterPopoverController dismissPopoverAnimated:YES];
    self.displayedComponent = component;
}


//set project model
- (void)setProjectModel:(ProjectModel *)projectModel
{
    //reset
    [self setComponentRatingIsComplete:NO];
    [self setWeightingIsComplete:NO];
    
    //get model
    self.currentProject = projectModel;
    self.availableComponents = [self.currentProject arrayWithComponents];
    [self setComponent:[self.availableComponents objectAtIndex:0]];
    
    //set name of project label
    self.projectNameLabel.text = [self.currentProject getProjectObject].name;
    
    [self setWeightingIsComplete:[self.currentProject getProjectHasBeenWeighted]];
    [self checkForCompleteness];
}

- (ProjectModel *)getProjectModel
{
    return self.currentProject;
}

#pragma mark ComponentSelectionRatingDelegate


- (NSArray *)getAvailableComponents
{
    return self.availableComponents;
}


- (NSString *)getCurrentProjectName
{
    return [self.currentProject.getProjectInfoArray objectAtIndex:1];
}

- (Component *)getSelectedComponent
{
    return [self.currentComponent getComponentObject];
}

//custom method that gets called when master view appears
- (void)masterViewIsThere
{
    //hide buttons in bottom bar
    [self.buttonsViewBottom setHidden:YES];
    
    //center header in top bar and project name label in bottom bar
    CGFloat xOriginOfTitleLabel = ((self.view.frame.size.width + 320)/2) - (self.screenTitleLabel.frame.size.width / 2) - 320;
    CGFloat xOriginOfNameLabel = ((self.view.frame.size.width + 320)/2) - (self.projectNameLabel.frame.size.width / 2) - 320;
    [self.screenTitleLabel setFrame:CGRectMake(xOriginOfTitleLabel, self.screenTitleLabel.frame.origin.y, self.screenTitleLabel.frame.size.width, self.screenTitleLabel.frame.size.height)];
    [self.projectNameLabel setFrame:CGRectMake(xOriginOfNameLabel, self.projectNameLabel.frame.origin.y, self.projectNameLabel.frame.size.width, self.projectNameLabel.frame.size.height)];
}

//custom method that gets called when master view disappears
- (void)masterViewIsNotThere
{
    //hide buttons in bottom bar
    [self.buttonsViewBottom setHidden:NO];
    
    //center header in top bar and project name label in bottom bar
    CGFloat xOriginOfTitleLabel = (self.view.frame.size.width/2) - (self.screenTitleLabel.frame.size.width / 2);
    CGFloat xOriginOfNameLabel = self.view.frame.size.width - (10 + self.projectNameLabel.frame.size.width);
    [self.screenTitleLabel setFrame:CGRectMake(xOriginOfTitleLabel, self.screenTitleLabel.frame.origin.y, self.screenTitleLabel.frame.size.width, self.screenTitleLabel.frame.size.height)];
    [self.projectNameLabel setFrame:CGRectMake(xOriginOfNameLabel, self.projectNameLabel.frame.origin.y, self.projectNameLabel.frame.size.width, self.projectNameLabel.frame.size.height)];
    
}


#pragma mark CharacteristicCell delegate methods

- (void)checkForCompleteness
{
    //rating complete?
    if ([self.currentProject ratingIsComplete]) {
        [self setComponentRatingIsComplete:YES];
    }
    //tell master view to update
    UINavigationController *masterNavigation = [self.splitViewController.viewControllers objectAtIndex:0];
    id visibleViewController = masterNavigation.visibleViewController;
    if ([visibleViewController isKindOfClass:[ComponentSelectionTableViewController class]]) {
        [visibleViewController reloadTableView];
    }
}

//save context
- (void)saveContext
{
    if (![self.currentComponent saveContext]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

//returns the cohesion value of the subgraph built up by
//requirements related to the currently displayed component
- (NSNumber *)getValueForCohesion
{
    return [self.currentComponent getComponentObject].cohesion;
}

//returns the coupling value of the subgraph built up by
//requirements related to the currently displayed component
- (NSNumber *)getValueForCoupling
{
    return [self.currentComponent getComponentObject].coupling;
}

#pragma mark IBActions 


- (IBAction)backToMainMenu:(id)sender {
    
    //if weighting has not been edited, ask for acknowledgement
    if (!self.weightingIsComplete) {
        
        //show alert to ask for acknowledgement to return with 50:50 weighting
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        ModalAlertViewController *modalAVC = (ModalAlertViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ModalAlertViewController"];
        modalAVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [modalAVC setStringForacknowledgeButton:@"YES"];
        [modalAVC setStringForcancelButton:@"NO"];
        [modalAVC setStringForTextLabel:@"You did not weight the Supercharacteristics. Please do so by taping the weighting button in the bottom bar. Do you want to return with the same weight for every Supercharacteristic?"];
        [modalAVC setStringForTitleLabel:@"Alert"];
        [modalAVC setDelegate:self];
        [self presentViewController:modalAVC animated:YES completion:nil];
        
    } else {
        
        //return to main menu
        [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self];
    }
}


#pragma mark ModalAlertViewControllerDelegate

//if modal view controller talks back (acknowledgement button has been klicked)
- (void)modalViewControllerHasBeenDismissedWithInput:(NSString *)input
{
    //return to main menu
    [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self];
}


#pragma mark WeightSuperCharacteristicsRatingDelegate


- (void)returnToMainMenu
{
    [self backToMainMenu:nil];
}

- (IBAction)weightingButtonPressed:(id)sender {
    [self setWeightingIsComplete:YES];
    [self checkForCompleteness];
    [self.splitViewController performSegueWithIdentifier:@"weightSuperChars" sender:self];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    /*
    barButtonItem.title = NSLocalizedString(@"Components", @"Components");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];*/
    //store popoverController and barButtonItem in splitview to make it available for previous/later view controllers
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    [splitViewController setMasterPopoverController:popoverController];
    [splitViewController setBarButtonItem:barButtonItem];
    [self.barButtonBackGroundView setHidden:NO];
    [self.barButton addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    /*
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    //self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObject:self.navigationItem.leftBarButtonItem, barButtonItem];
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];*/
    //reset the splitviewcontroller's properties to nil
    SmartSourceSplitViewController *splitViewController = (SmartSourceSplitViewController *)self.splitViewController;
    [splitViewController setMasterPopoverController:nil];
    [splitViewController setBarButtonItem:nil];
    [self.barButtonBackGroundView setHidden:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.characteristics objectAtIndex:1]  count] + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    } else if (section > [[self.characteristics objectAtIndex:0] count]){
        return 1;
    }
    //else
    return [[[self.characteristics objectAtIndex:1] objectAtIndex:(section-1)] count] + 1;
}


//necessary for iOS7 to change cells background color from white
//available after iOS6
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //section 0 - component info
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = nil;
        //row 0 - componentInfoHeaderCell
        if (indexPath.row == 0) {
            
            //get cell
            static NSString *CellIdentifier = @"componentInfoHeaderCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //set label
            UIView *contentView = [cell viewWithTag:20];
            UILabel *text = (UILabel *)[contentView viewWithTag:10];
            Component *component = [self.currentComponent getComponentObject];
            [text setText:component.name];
            
        //row 1 - componentInfoDescriptionCell
        } else if (indexPath.row == 1) {
            
            //get cell
            static NSString *CellIdentifier = @"componentInfoDescriptionCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //get label and component
            UIView *contentView = [cell viewWithTag:20];
            UILabel *text = (UILabel *)[contentView viewWithTag:10];
            UIButton *moreLessButton = (UIButton *)[contentView viewWithTag:11];
            [moreLessButton setTitle:@"more" forState:UIControlStateNormal];
            
            //set size and text
            [text setText:self.textDescriptionLabel];
            
            //put read more button at the end of text view
            CGRect frameSuperView = moreLessButton.superview.frame;
            CGRect frameReadMoreButton = CGRectMake((frameSuperView.size.width - moreLessButton.frame.size.width), (frameSuperView.size.height - moreLessButton.frame.size.height), moreLessButton.frame.size.width, moreLessButton.frame.size.height);
            [moreLessButton setFrame:frameReadMoreButton];
            
            //if text has been shortened
            Component *rightComponent = [self.currentComponent getComponentObject];
            if ([rightComponent.descr length] > 200) {
                //set button visible and action
                UIButton *readMoreButton = (UIButton *)[contentView viewWithTag:11];
                [readMoreButton addTarget:self action:@selector(showHideFullDescription) forControlEvents:UIControlEventTouchUpInside];
                [readMoreButton setHidden:NO];
            } else {
                //set button invisible
                UIButton *readMoreButton = (UIButton *)[contentView viewWithTag:11];
                [readMoreButton setHidden:YES];
            }
            
        //rows 2... - componentInfoContentCell
        } else {
            //get cell
            static NSString *CellIdentifier = @"componentInfoContentCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //set label
            UIView *contentView = [cell viewWithTag:20];
            UILabel *info = (UILabel *)[contentView viewWithTag:10];
            UILabel *infoValue = (UILabel *)[contentView viewWithTag:11];
            Component *component = [self.currentComponent getComponentObject];
            
            if (indexPath.row == 2) {
                [info setText:@"Estimated Hours"];
                [infoValue setText:[component.estimatedhours stringValue]];
            } else if (indexPath.row == 3) {
                [info setText:@"Priority"];
                [infoValue setText:component.priority];
            } else if (indexPath.row == 4) {
                [info setText:@"Last Modifier"];
                [infoValue setText:component.modifier];
            }
            //replace empty string by N.A.
            if ([infoValue.text isEqualToString:@""] || (!infoValue.text)) {
                NSLog(@"true");
                [infoValue setText:@"N.A."];
            }
        }
    return cell;

    } else if (indexPath.section > ([[self.characteristics objectAtIndex:0] count])){
        
        static NSString *CellIdentifier = @"emptySpaceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
        
    } else {
        
        //the first row of each section should present a supercharacteristik 
        if (indexPath.row == 0) {
            SuperCharacteristic *superChar = [[self.characteristics objectAtIndex:0] objectAtIndex:(indexPath.section-1)];
            static NSString *CellIdentifier = @"superCharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //set label
            UIView *contentView = [cell viewWithTag:20];
            UILabel *text = (UILabel *)[contentView viewWithTag:10];
            text.text = superChar.name;
            return cell;
            
        } else {
            
            //soda - first two cells of communication complexity are different
            if (indexPath.section == (indexOfCommunicationComplexity+1)) {
                if ((indexPath.row == (indexOfCohesionCell+1)) || (indexPath.row == (indexOfCouplingCell+1))) {
                    Characteristic *rightCharacteristic = [[[self.characteristics objectAtIndex:1] objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row-1];
                    static NSString *CellIdentifier = @"sodaCell";
                    SodaCharacteristicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    [cell setCharacteristic:rightCharacteristic andDelegate:self];
                    return cell;
                }
            }
            
            //return cell of subcharacteristic
            static NSString *CellIdentifier = @"characteristicCell";
            CharacteristicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //get characteristic
            Characteristic *rightCharacteristic = [[[self.characteristics objectAtIndex:1] objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row-1];
            //return cell with characteristic
            [cell setCharacteristic:rightCharacteristic andDelegate:self];
            return cell;
        }
    }
}
//
//automatic detection of indices of SODA characteristics in characteristics
//--> used by cellForRowAtIndexPath
- (void)getIndicesForCommunicationComplexity
{
    //get indices for
    for (int i=0; i<[[self.characteristics objectAtIndex:0] count]; i++) {
        SuperCharacteristic *superChar = [[self.characteristics objectAtIndex:0] objectAtIndex:i];
        if ([superChar.name isEqualToString:@"Communication Complexity"]) {
            indexOfCommunicationComplexity = i;
            for (int y=0; y<[[[self.characteristics objectAtIndex:1] objectAtIndex:i] count]; y++) {
                Characteristic *previousChar = [[[self.characteristics objectAtIndex:1] objectAtIndex:i] objectAtIndex:y];
                if ([previousChar.name isEqualToString:@"Autonomy of requirements within this component"]) {
                    indexOfCohesionCell = y;
                } else if ([previousChar.name isEqualToString:@"Number of inter-component requirements links"]) {
                    indexOfCouplingCell = y;
                }
            }
            break;
        }
    }
}

#pragma expand and shrink component description

- (CGFloat)calculateHeightForDescriptionCell
{
    //set component text
    Component *component = [self.currentComponent getComponentObject];
    self.textDescriptionLabel = component.descr;
    
    //cut text if longer than 200
    if (([self.textDescriptionLabel length] > 200) && (!self.tableViewShowsFullComponentDescription)) {
        self.textDescriptionLabel = [[self.textDescriptionLabel substringToIndex:194] stringByAppendingString:@"......"];
    }
    
    //calculate hight
    CGSize maximumLabelSize = CGSizeMake(510, FLT_MAX);
    CGSize expectedLabelSize = [self.textDescriptionLabel sizeWithFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:17.0] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    self.heightDescriptionLabel = expectedLabelSize.height;
    return self.heightDescriptionLabel + 40;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //for description label, calculate cell height from description length
    if ((indexPath.section == 0) && (indexPath.row == 1)) {
        return [self calculateHeightForDescriptionCell];
    //last cell to leave space
    } else if (indexPath.section > [[self.characteristics objectAtIndex:0] count]) {
        return 30;
    }
    if (indexPath.row == 0) {
        return 75;
    //soda cells higher
    } else if (indexPath.section == (indexOfCommunicationComplexity + 1)) {
        if (indexPath.row == (indexOfCohesionCell+1)) {
            return 100;
        } else if (indexPath.row == (indexOfCouplingCell+1)) {
            return 100;
        }
    }
    //else
    return 50;
}


//method to be called if description should be expanded to full description
- (void)showHideFullDescription
{
 
    //get cell
    NSIndexPath *index = [NSIndexPath indexPathForItem:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    //get label and component
    UIView *contentView = [cell viewWithTag:20];
    UILabel *text = (UILabel *)[contentView viewWithTag:10];
    UIButton *moreLessButton = (UIButton *)[contentView viewWithTag:11];
    //update hightforrowatindexpath
    [self.tableView beginUpdates];
    self.tableViewShowsFullComponentDescription = !self.tableViewShowsFullComponentDescription;
    [self.tableView endUpdates];
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        //set label to full component description text
        //Component *component = [self.currentComponent getComponentObject];
        [text setText:self.textDescriptionLabel];
        if ([moreLessButton.titleLabel.text isEqualToString:@"more"]) {
            [moreLessButton setTitle:@"less" forState:UIControlStateNormal];
        } else if ([moreLessButton.titleLabel.text isEqualToString:@"less"]){
            [moreLessButton setTitle:@"more" forState:UIControlStateNormal];
        }
    }];
}

@end
