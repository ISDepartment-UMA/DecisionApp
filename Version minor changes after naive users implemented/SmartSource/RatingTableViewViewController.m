//
//  RatingTableViewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingTableViewViewController.h"
#import "Slider.h"
#import "UIKit/UIKit.h"
#import "SBJson.h"
#import "AvailableSuperCharacteristic.h"
#import "AvailableCharacteristic.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "DecisionTableViewController.h"
#import "Project+Factory.h"
#import "ChartViewController.h"
#import "ComponentModel.h"
#import "CharacteristicCell.h"
#import "SmartSourceAppDelegate.h"
#import "SmartSourceSplitViewController.h"
#import "UIImageView+PermanentScroller.h"
#import "ComponentSelectionTableViewController.h"


@interface RatingTableViewViewController ()

@property (strong, nonatomic) ComponentModel *currentComponent;
@property (strong, nonatomic) ProjectModel *currentProject;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *topBar;

@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;

//barbutton
@property (strong, nonatomic) IBOutlet UIView *barButtonBackGroundView;
@property (strong, nonatomic) IBOutlet UIButton *barButton;


//array of necessary rating characteristics 
@property (strong, nonatomic) NSArray *characteristics;
//split view
//available components and current component+project
@property (strong, nonatomic) NSArray *availableComponents;

//show full description of component
@property (nonatomic) BOOL tableViewShowsFullComponentDescription;
@property (nonatomic) CGFloat heightDescriptionLabel;
@property (nonatomic, strong) NSString *textDescriptionLabel;





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



//methods to implement:

//check for completeness

- (void)checkForCompleteness
{
    if ([self.currentProject ratingIsComplete]) {
        //show alert view that rating is complete
        //show allert that will ask for acknoledgement
        NSString *message = @"The rating is now complete. You can access your results via the Main Menu";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating Complete" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    //tell master view to update
    UINavigationController *masterNavigation = [self.splitViewController.viewControllers objectAtIndex:0];
    id visibleViewController = masterNavigation.visibleViewController;
    if ([visibleViewController isKindOfClass:[ComponentSelectionTableViewController class]]) {
        [visibleViewController reloadTableView];
    }
    
    
}

- (void)saveContext
{
    if (![self.currentComponent saveContext]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}




//sets the component currently displayed in the ratingtableview
- (void)setComponent:(Component *)component
{
    self.tableViewShowsFullComponentDescription = NO;
    
    //initialize model for component
    self.currentComponent = [[ComponentModel alloc] initWithComponent:component];
    
    //get rating characteristics
    self.characteristics = [self.currentComponent getCharacteristics];

    
    [self.tableView reloadData];
    
    //if component has been selected, dismiss popovercontroller
    SmartSourceSplitViewController *splitVC = (SmartSourceSplitViewController *)self.splitViewController;
    [splitVC.masterPopoverController dismissPopoverAnimated:YES];
    self.displayedComponent = component;
    
    
    
    

}

//set project model
- (void)setProjectModel:(ProjectModel *)projectModel
{
    //get model
    self.currentProject = projectModel;
    self.availableComponents = [self.currentProject arrayWithComponents];
    [self setComponent:[self.availableComponents objectAtIndex:0]];
    
    //set name of project label
    self.projectNameLabel.text = [self.currentProject getProjectObject].name;
    
    
}

- (ProjectModel *)getProjectModel
{
    return self.currentProject;
}

- (IBAction)backToMainMenu:(id)sender {
    
    [self.splitViewController performSegueWithIdentifier:@"mainMenu" sender:self];
}

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //show scrollers once and they won't disappear
    [self.tableView flashScrollIndicators];

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
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    } else {
        return [[[self.characteristics objectAtIndex:1] objectAtIndex:(section-1)] count] + 1;
    }
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
            //[cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, (self.heightDescriptionLabel + 40))];
            //[contentView setFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, self.heightDescriptionLabel + 40)];
            //[text setFrame:CGRectMake(20, 9, (contentView.frame.size.width-101), self.heightDescriptionLabel)];
            
            
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

        
    
    } else if (indexPath.section > [[self.characteristics objectAtIndex:0] count]){
        
        static NSString *CellIdentifier = @"emptySpaceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
        
        
    } else {
    
        //the first row of each section should present a supercharacteristik with a slider to weight is
        if (indexPath.row == 0) {
            
            SuperCharacteristic *superChar = [[self.characteristics objectAtIndex:0] objectAtIndex:(indexPath.section-1)];
            //return cell of supercharacteristic with weight-slider
            //get cell
            static NSString *CellIdentifier = @"superCharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //set label
            UIView *contentView = [cell viewWithTag:20];
            UILabel *text = (UILabel *)[contentView viewWithTag:10];
            text.text = superChar.name;
            
            //add action to slider
            Slider *slider = (Slider *)[contentView viewWithTag:11];
            //change appearence
            UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"thumb.jpg"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];
            UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"nothumb.jpg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)];
            
            UIImage *sliderThumbImage = [UIImage imageNamed: @"thumb.jpg"];
            
            [slider setThumbImage:sliderThumbImage forState:UIControlStateNormal];
            [slider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
            [slider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];

            
            //set the sliders rating controller to self in order for it to be able to talk back to us and save its value
            [slider setSliderDelegate:self];
            
            
            //slider value according to stored value in core database
            slider.value = [superChar.weight floatValue];
            
            return cell;
            
        } else {
            
            //return cell of subcharacteristic
            static NSString *CellIdentifier = @"characteristicCell";
            CharacteristicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //get characteristic
            Characteristic *rightCharacteristic = [[[self.characteristics objectAtIndex:1] objectAtIndex:(indexPath.section-1)] objectAtIndex:indexPath.row-1];
            
            //return cell with characteristic
            [cell setCharacteristic:rightCharacteristic andDelegate:self];
            return cell;
            //return [[CharacteristicCell alloc] initWithCharacteristic:rightCharacteristic andDelegate:self];
            
        }
    } 

}


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
    CGSize expectedLabelSize = [self.textDescriptionLabel sizeWithFont:[UIFont fontWithName:@"BitstreamVeraSans-Roman" size:17.0] constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
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
        return 90;
    } else {
        return 50;
    }
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
        
        //[moreLessButton setFrame:CGRectMake(moreLessButton.frame.origin.x, (cell.frame.size.height-30), moreLessButton.frame.size.width, moreLessButton.frame.size.height)];
        //change size of cell
        //[cell setFrame: CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, (self.heightDescriptionLabel + 40))];
        //[contentView setFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, contentView.frame.size.width, self.heightDescriptionLabel + 40)];
        //[text setFrame:CGRectMake(text.frame.origin.x, text.frame.origin.y, text.frame.size.width, self.heightDescriptionLabel + 20)];
        
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





//save weight from slider into model
- (void)saveValueForSlider:(Slider *)slider
{
    //get name of supercharacteristic
    UILabel *textLabel = (UILabel *)[slider.superview viewWithTag:10];
    
    //save weight into model
    [self.currentComponent saveWeight:[NSNumber numberWithFloat:slider.value] forSuperCharacteristic:textLabel.text];
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
        [resOVC initializeClassificationForProject:[self.currentProject getProjectID]];
       
    }
}


@end
