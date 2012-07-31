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
#import "ComponentsTableViewController.h"
#import "UIKit/UIKit.h"
#import "SBJson.h"
#import "AvailableSuperCharacteristic.h"
#import "AvailableCharacteristic.h"
#import "Component.h"
#import "Characteristic+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "DecisionTableViewController.h"
#import "ShowClassificationTableViewController.h"
#import "Project+Factory.h"
#import "ResultMasterViewController.h"
#import "ChartViewController.h"

@interface RatingTableViewViewController ()
@property (strong, nonatomic) NSArray *SuperCharacteristics;
@property (strong, nonatomic) NSArray *Characteristics;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString *currentProject;
@property (strong, nonatomic) NSArray *currentComponent;
@property (strong, nonatomic) ComponentsTableViewController *componentScreen;


@property (strong, nonatomic) NSDictionary *componentRating;



@end

@implementation RatingTableViewViewController
@synthesize componentScreen = _componentScreen;
@synthesize currentComponent = _currentComponent;
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize componentRating = _componentRating;
@synthesize currentProject = _currentProject;





//returns an nsdictionary with component info for a given component id
- (NSDictionary *)getComponentForID:(NSString *)componentID
{
    //login data from nsuserdefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSString *serviceUrl = @"";
    NSString *login = @"";
    NSString *password = @"";
    
    if (loginData != nil) {
        
        //decode url to pass it in http request
        serviceUrl = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)[loginData objectAtIndex:0], NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        login = [loginData objectAtIndex:1];
        password = [loginData objectAtIndex:2];
    } else {
        return nil;
    } 
    
    //JSON request to web service
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSString *url = [[[[[[[[@"http://wifo1-52.bwl.uni-mannheim.de:8080/axis2/services/DataFetcher/getComponentInfo?url=" stringByAppendingString:serviceUrl] stringByAppendingString:@"&login="] stringByAppendingString:login] stringByAppendingString:@"&password="] stringByAppendingString:password] stringByAppendingString:@"&componentID="] stringByAppendingString:componentID] stringByAppendingString:@"&response=application/json"];
    
    //sending request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *responsedic = [parser objectWithString:json_string error:nil];
    NSDictionary *returnedObjects = [responsedic objectForKey:@"return"];
    return returnedObjects;
}


//sets the component currently displayed in the ratingtableview
- (void)setComponent:(NSString *)componentID ofProject:(NSString *)projectID withRatingCharacteristics:(NSArray *)characteristics
{
    
    //set used rating characteristics and current project
    self.SuperCharacteristics = [characteristics objectAtIndex:0];
    self.Characteristics = [characteristics objectAtIndex:1];
    self.currentProject = projectID;
    
    
    //setting the componentInfo
    NSDictionary *component = [self getComponentForID:componentID];
    NSString *estimatedHours = [NSString stringWithFormat:@"%d", [[component objectForKey:@"estimatedhours"] integerValue]];
    self.currentComponent = [NSArray arrayWithObjects:componentID, [component objectForKey:@"name"], [component objectForKey:@"description"], [component objectForKey:@"priority"], estimatedHours, [component objectForKey:@"modifier"], nil];
    
    [self.tableView reloadData];
    self.navigationController.navigationBarHidden = YES;
    [self.componentScreen checkForCompleteness];

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
    
    //set the components table view's rating screen to self
    [super viewDidLoad];
    UINavigationController *masterNavigation = [self.splitViewController.viewControllers objectAtIndex:0];
    ComponentsTableViewController *componentTVC = [masterNavigation.viewControllers objectAtIndex:1];
    componentTVC.ratingScreen = self;
    self.componentScreen = componentTVC;
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;

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
            UILabel *text = (UILabel *)[cell viewWithTag:10];
            text.text = [self.SuperCharacteristics objectAtIndex:indexPath.section];
            
            //add action to slider
            Slider *slider = (Slider *)[cell viewWithTag:11];
            
            //set the sliders rating controller to self in order for it to be able to talk back to us and save its value
            [slider setRatingController:self];
            
            
            //slider value according to stored value in core database
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", text.text];
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", self.currentProject];
            NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"componentID =%@", [self.currentComponent objectAtIndex:0]];
            NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, predicate3, nil];
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];    
            
            NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
            NSError *error = nil;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            SuperCharacteristic *superChar = [matches lastObject];
            slider.value = [superChar.weight floatValue];
            
            return cell;
            
        } else {
            
            //return cell of subcharacteristic
            //get cell
            static NSString *CellIdentifier = @"characteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //add buttons and label
            cell = [self makeCharacteristicCell:cell];
            cell.textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1];
        
            //check buttons according to the available rating
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Characteristic"];
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", cell.textLabel.text];
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", self.currentProject];
            NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"componentID =%@", [self.currentComponent objectAtIndex:0]];
            NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, predicate3, nil];
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];    
            
            NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
            NSError *error = nil;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            //write the value into the characteristic value
            Characteristic *rightCharacteristic = [matches lastObject];
            int value = [rightCharacteristic.value intValue];
            if (value != 0) {
                UIButton *button = (UIButton *)[cell.contentView viewWithTag:[rightCharacteristic.value intValue]];
                UIButton *theSameButton = button;
                theSameButton.selected = YES;
                [button removeFromSuperview];
                [cell.contentView addSubview:theSameButton];
            }
            
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
    [highTextLabel setBackgroundColor:[UIColor clearColor]];
    
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
    [mediumTextLabel setBackgroundColor:[UIColor clearColor]];

    
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
    [lowTextLabel setBackgroundColor:[UIColor clearColor]];

    
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
    
    //check for other buttons in the same cell and uncheck them
    for (UIButton *Radiobutton in [button.superview subviews]) {
        if ([Radiobutton isKindOfClass:[UIButton class]] && ![Radiobutton isEqual:button]) {
            [Radiobutton setSelected:NO];
        }
    }
    
    //check the touched button
    if (!button.selected) {
        button.selected = !button.selected;
        
        //get the cell of the button
        UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
        
        //store selection in the core database
        //get the right characteristic by name, projectID, componentID
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Characteristic"];
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", cell.textLabel.text];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", self.currentProject];
        NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"componentID =%@", [self.currentComponent objectAtIndex:0]];
        NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, predicate3, nil];
        request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];    
        
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        //write the value into the characteristic value
        Characteristic *rightCharacteristic = [matches lastObject];
        rightCharacteristic.value = [NSNumber numberWithInt:button.tag];

        //save context
        if (![self.managedObjectContext save:&error]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
        
        //check for rating completeness
        [self.componentScreen checkForCompleteness];
    }
}


//method, sliders from a supercharacteristiccell call to save their changed value in the core database
- (void)saveValueForSlider:(Slider *)slider
{
    //get the supercharacteristic from the label on the cell
    UILabel *textLabel = (UILabel *)[slider.superview viewWithTag:10];
    
    //store slider value in core database
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SuperCharacteristic"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name =%@", textLabel.text];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"projectID =%@", self.currentProject];
    NSArray *predicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
    request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];    
    
    NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //set weight of this supercharacteristic for ALL COMPONENTS of the current project
    for (int i=0; i<[matches count]; i++) {
        SuperCharacteristic *rightSuperCharacteristic = [matches objectAtIndex:i];
        rightSuperCharacteristic.weight = [NSNumber numberWithFloat:slider.value];
    }
    
    
    if (![self.managedObjectContext save:&error]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The Project Rating could not be saved!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
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
    if ([segue.identifier isEqualToString:@"atAGlance"]) {
        ChartViewController *resOVC = segue.destinationViewController;
        resOVC.managedObjectContext = self.managedObjectContext;
        [resOVC setResultMasterScreen:sender];
    }
}


@end
