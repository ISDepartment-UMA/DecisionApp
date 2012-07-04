//
//  RatingTableViewViewController.m
//  SmartSource
//
//  Created by Lorenz on 21.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingTableViewViewController.h"
#import "Slider.h"
#import "ComponentsTableViewController.h"
#import "UIKit/UIKit.h"
#import "SBJson.h"
#import "AvailableSuperCharacteristic.h"
#import "AvailableCharacteristic.h"
#import "Component.h"

@interface RatingTableViewViewController ()
@property (strong, nonatomic) NSArray *SuperCharacteristics;
@property (strong, nonatomic) NSArray *Characteristics;
@property (strong, nonatomic) NSArray *currentComponent;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableDictionary *currentRating;

@property (strong, nonatomic) NSDictionary *componentRating;



@end

@implementation RatingTableViewViewController
@synthesize currentComponent = _currentComponent;
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize currentRating = _currentRating;
@synthesize componentRating = _componentRating;





//returns an nsdictionary with component info for a given component id
- (NSDictionary *)getComponentForID:(NSString *)componentID
{
    //login data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *login = @"";
    NSString *password = @"";
    if (loginData != nil) {
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getComponentInfo?login=" stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
}


//sets the component currently displayed in the ratingtableview
- (void)setComponent:(NSString *)componentID
{
    [self getRatingCharacteristics];
    
    
    //setting the componentInfo
    NSDictionary *component = [self getComponentForID:componentID];
    NSString *estimatedHours = [NSString stringWithFormat:@"%d", [[component objectForKey:@"estimatedhours"] integerValue]];
    self.currentComponent = [NSArray arrayWithObjects:componentID, [component objectForKey:@"name"], [component objectForKey:@"description"], [component objectForKey:@"priority"], estimatedHours, [component objectForKey:@"modifier"], nil];
    
    [self.tableView reloadData];
    self.navigationController.navigationBarHidden = YES;

}





/*
     - prepares the two arrays self.supercharacteristics and self.characteristics
    self.supercharacteristics afterwards contains the names of all available supercharacteristics
    self.characteristics contains a 2 dimensional array with: the first one adresses the supercharacteristics
    in the order of self.supercharacteristics, the second dimension contains all characteristics that belong
    to the supercharacteristic of the first dimension
 
     - prepares self.currentRating
    self.currentrating is an nsdictionary with the supercharacteristics' names as keys
    the objects are nsarrays that cotain:
        at 0: an NSNumber with the weight of the current supercharacteristic
        at 1: an NSDictionary with the names of characteristics of the chosen supercharacteristic as keys
                and an NSNumber which contains the current rating of that characteristic
 
*/
- (void)getRatingCharacteristics
{
    //getting characteristics from core database
    //get all supercharacteristics
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //initialize arrays for super- and subcharacteristics
    NSMutableArray *superchar = [NSMutableArray array];
    NSMutableArray *subchar = [NSMutableArray array];
    
    //initialize dictionary for currentRating
    NSMutableDictionary *currRating = [NSMutableDictionary dictionary];
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //initialize ratingdictionary for current supercharacteristic
        NSArray *currSuperCharacteristic = [NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSMutableDictionary dictionary], nil];
        
        //add supercharacteristics name to array
        [superchar addObject:tmpasc.name];
        
        //add all subcharacteristics names to array
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *enumerator = [NSArray arrayWithArray:[tmpasc.availableSuperCharacteristicOf allObjects]];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            [tmp addObject:tmpcharacteristic.name];
            
            //add every subcharacteristic to dictionary
            [[currSuperCharacteristic objectAtIndex:1] setObject:[NSNumber numberWithInt:0] forKey:tmpcharacteristic.name];
            
        }
        //add supercharacteristic to currentRatingDictionary
        [currRating setObject:currSuperCharacteristic forKey:tmpasc.name];
        [subchar addObject:tmp];
        
        
    }
    //set arrays
    self.SuperCharacteristics = superchar;
    self.Characteristics = subchar;
    self.currentRating = currRating;
    
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidUnload
{

    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


//checks weather the rating of the currently displayed component is complete or not
- (BOOL)ratingIsComplete
{
    for (int superChar=0; superChar<[self.SuperCharacteristics count]; superChar++) {
        for (int subChar=0; subChar<[[self.Characteristics objectAtIndex:superChar] count]; subChar++) {
            NSArray *superCharacteristic = [self.currentRating objectForKey:[self.SuperCharacteristics objectAtIndex:superChar]];
            NSDictionary *subCharacteristics = [superCharacteristic objectAtIndex:1];
            NSNumber *rating = [subCharacteristics objectForKey:[[self.Characteristics objectAtIndex:superChar] objectAtIndex:subChar]];
            if ([[rating stringValue] isEqualToString:@"0"]) {
                return NO;
            }
        }
    }
    return YES;
    
}

//sends the current rating of the component back to the componenttableviewcontroller, which will then safe the ratings
- (void)saveComponent{
    
    //get ComponentsViewController
    UISplitViewController *splitView = [self.navigationController splitViewController];
    UINavigationController *navigation = [splitView.viewControllers objectAtIndex:0];
    if ([navigation.visibleViewController isKindOfClass:[ComponentsTableViewController class]]) {
        ComponentsTableViewController *master = (ComponentsTableViewController *)navigation.visibleViewController;
        //send rating of current component
        [master sendRating:self.currentRating forComponent:[self.currentComponent objectAtIndex:0]];
    }
}

//makes sure, that there's no navigation bar while RatingTableViewController is on screen
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of supercharacteristics
    return 1 + [self.SuperCharacteristics count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return number of characteristics that belong to the supercharacteristic
    if (section < [self.SuperCharacteristics count]) {
        return 1+[[self.Characteristics objectAtIndex:section] count];
    } else {
        return 7;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //the first row of each section should present a supercharacteristik with a slider to weight it
    if (indexPath.section < [self.SuperCharacteristics count]) {
        
        
        if (indexPath.row == 0) {
            
            //return cell of supercharacteristic with weight-slider
            //get cell
            static NSString *CellIdentifier = @"superCharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //set label
            UILabel *text = (UILabel *)[cell.contentView viewWithTag:10];
            text.text = [self.SuperCharacteristics objectAtIndex:indexPath.section];

            //add action to slider
            Slider *slider = (Slider *)[cell viewWithTag:11];
            [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
            return cell;
            
        } else {
            
            //return cell of subcharacteristic
            //get cell
            static NSString *CellIdentifier = @"characteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //add buttons and label
            cell = [self makeCharacteristicCell:cell];
            cell.textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
            return cell; 
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
     cell.textLabel.text = [componentInfo objectAtIndex:row];
     if (row > 0) {
          cell.detailTextLabel.text = [self.currentComponent objectAtIndex:(row-1)];
     }
    
     return cell;
 }



//building the characteristiccell with checkboxes for high, medium and low
- (UITableViewCell *)makeCharacteristicCell:(UITableViewCell *)cell
{
    //building buttons, textlabels and add them to cell
    //low has tag 1, medium tag 2, high tag 3
    
    //high
    CGRect HighButtonFrame = CGRectMake(500, 10, 50, 25);
    UIButton *highRadioButton = [self getRadioButton];
    [highRadioButton setFrame:HighButtonFrame];
    highRadioButton.tag = 3;
    [cell.contentView addSubview:highRadioButton];
    CGRect highTextFrame = CGRectMake(550, 10, 50, 25);
    UILabel *highTextLabel = [[UILabel alloc] initWithFrame:highTextFrame];
    highTextLabel.text = @"high";
    [cell.contentView addSubview:highTextLabel];
    
    //medium
    CGRect MediumButtonFrame = CGRectMake(350, 10, 50, 25);
    UIButton *mediumRadioButton = [self getRadioButton];
    [mediumRadioButton setFrame:MediumButtonFrame];
    mediumRadioButton.tag = 2;
    [cell.contentView addSubview:mediumRadioButton];
    CGRect mediumTextFrame = CGRectMake(400, 10, 70, 25);
    UILabel *mediumTextLabel = [[UILabel alloc] initWithFrame:mediumTextFrame];
    mediumTextLabel.text = @"medium";
    [cell.contentView addSubview:mediumTextLabel];
    
    //low
    CGRect LowButtonFrame = CGRectMake(250, 10, 50, 25);
    UIButton *lowRadioButton = [self getRadioButton];
    lowRadioButton.tag = 1;
    [lowRadioButton setFrame:LowButtonFrame];
    [cell.contentView addSubview:lowRadioButton];
    CGRect lowTextFrame = CGRectMake(300, 10, 50, 25);
    UILabel *lowTextLabel = [[UILabel alloc] initWithFrame:lowTextFrame];
    lowTextLabel.text = @"low";
    [cell.contentView addSubview:lowTextLabel];
    
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    return cell;
}




// building the radio button
- (UIButton *)getRadioButton
{
    UIButton *Radiobutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [Radiobutton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [Radiobutton setImage:[UIImage imageNamed:@"checkedbox.png"] forState:UIControlStateSelected];
    [Radiobutton setFrame:CGRectMake(0, 0, 17, 17)];
    [Radiobutton addTarget:self action:@selector(checkboxButton:) forControlEvents:UIControlEventTouchUpInside];
    return Radiobutton;
}


//action for clicking the button
- (IBAction)checkboxButton:(UIButton *)button{
    for (UIButton *Radiobutton in [button.superview subviews]) {
        if ([Radiobutton isKindOfClass:[UIButton class]] && ![Radiobutton isEqual:button]) {
            [Radiobutton setSelected:NO];
        }
    }
    
    if (!button.selected) {
        button.selected = !button.selected;

        //get the cell of the button
        UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
        
        //get the appropriate supercharacteristic of the current cell
        NSString *cellsSuperCharacteristic = [self.SuperCharacteristics objectAtIndex:[self.tableView indexPathForCell:cell].section];
        
        //write selected rating (= tag of selected button) into the right characteristic of the right supercharacteristic in the current rating
        [[[self.currentRating objectForKey:cellsSuperCharacteristic] objectAtIndex:1] setObject:[NSNumber numberWithInt:button.tag] forKey:cell.textLabel.text];
        
        //if rating is already complete, save new component data
        if ([self ratingIsComplete]) {
            [self saveComponent];
        }
        
    }
}

//if the slider changes, its value is written into the weight of the supercharacteristic in the current rating
- (IBAction)sliderChange:(Slider *)slider{
    
    //get the supercharacteristic from the label on the cell
    UILabel *textLabel = (UILabel *)[slider.superview viewWithTag:10];
    NSString *currSuperCharacteristic = textLabel.text;
    
    //write the value into the right supercharacteristic's weight in the current rating
    NSNumber *rating = [[self.currentRating objectForKey:currSuperCharacteristic] objectAtIndex:0];
    rating = [NSNumber numberWithFloat:slider.value];
    
    //if rating is already complete, save new component data
    if ([self ratingIsComplete]) {
        [self saveComponent];
    }
    
}

//RootViewController.m
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
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
