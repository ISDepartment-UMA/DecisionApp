//
//  CharacteristicsTableViewController.m
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CharacteristicsTableViewController.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "AlertView.h"


@interface CharacteristicsTableViewController ()
@property (nonatomic, strong) NSArray *SuperCharacteristics;
@property (nonatomic, strong) NSArray *Characteristics;


@end

@implementation CharacteristicsTableViewController
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;




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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getRatingCharacteristics];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return number of supercharacteristics
    return 1+[self.SuperCharacteristics count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    //return number of characteristics that belong to the supercharacteristic
    if (section == 0) {
        return 1;
    } else {
        return 2+ [[self.Characteristics objectAtIndex:(section-1)] count];
    }

}

- (void)addSuperCharacteristic:(UIButton *)sender
{
    
    //show allert that will ask for name of new supercharacteristic
    NSString *message = @"Please enter the name for your new Super Characteristic!";
    AlertView * alert = [[AlertView alloc] initWithTitle:@"Super Characteristic" message:message delegate:self cancelButtonTitle:@"Insert" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)addCharacteristic:(UIButton *)sender
{
    //show allert that will ask for name of new characteristic
    NSString *message = @"Please enter the name for your new Characteristic!";
    AlertView * alert = [[AlertView alloc] initWithTitle:@"Characteristic" message:message delegate:self cancelButtonTitle:@"Insert" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    alert.stringToPass = [self.SuperCharacteristics objectAtIndex:[self.tableView indexPathForCell:cell].section-1];
    [alert show];
}

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    
    //if insertbutton clicked and title is super characteristic and input not empty
    if ((buttonIndex == 0) && ([alertView.title isEqualToString:@"Super Characteristic"]) && (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""])) {
        
        //then insert the new supercharacteristic
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:[[alertView textFieldAtIndex:0] text] toManagedObjectContext:self.managedObjectContext];
        
        //save context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self getRatingCharacteristics];
        [self.tableView reloadData];
        
    //if insertbutton clicked and title is characteristic and input not empty
    } else if ((buttonIndex == 0) && ([alertView.title isEqualToString:@"Characteristic"]) && (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""])) {
        
        //then insert the new characteristic
        [AvailableCharacteristic addNewAvailableCharacteristic:[[alertView textFieldAtIndex:0] text] toSuperCharacteristic:alertView.stringToPass toManagedObjectContext:self.managedObjectContext];
        
        //save context
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self getRatingCharacteristics];
        [self.tableView reloadData];
        
    }
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        //return button cell to add new supercharacteristic in the firts section
        static NSString *CellIdentifier = @"AddSuperCharacteristic";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UIButton *button = (UIButton *)[cell.contentView viewWithTag:10];
        [button addTarget:self action:@selector(addSuperCharacteristic:) forControlEvents:UIControlEventTouchDown];
        return cell;
        
    } else {
        
        //in the first row of each section add the name of the supercharacteristic
        if (indexPath.row == 0) {
            
            //return cell of supercharacteristic
            //get cell
            static NSString *CellIdentifier = @"SuperCharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            //set label
            cell.textLabel.text = [self.SuperCharacteristics objectAtIndex:indexPath.section-1];
            return cell;
        
        //beginning with the second row of each section, show the subcharacteristics
        } else if (indexPath.row < [[self.Characteristics objectAtIndex:indexPath.section-1] count]+1) {
            
            //return cell of subcharacteristic
            //get cell
            static NSString *CellIdentifier = @"CharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //add label
            cell.textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row-1];
            return cell; 
            
        //in the last row of each section, add a button to add a new subcharacteristic to the supercharacteristic
        } else {
            static NSString *CellIdentifier = @"AddCharacteristic";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            UIButton *button = (UIButton *)[cell.contentView viewWithTag:10];
            [button addTarget:self action:@selector(addCharacteristic:) forControlEvents:UIControlEventTouchDown];
            return cell;
        }
    }

    
}

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
    
    //iterate through the supercharacteristics
    AvailableSuperCharacteristic *tmpasc = nil;
    for (int i=0; i<[matches count]; i++) {
        tmpasc = [matches objectAtIndex:i];
        
        //add supercharacteristics name to array
        [superchar addObject:tmpasc.name];
        
        //add all subcharacteristics names to array
        NSMutableArray *tmp = [NSMutableArray array];
        NSArray *enumerator = [NSArray arrayWithArray:[tmpasc.availableSuperCharacteristicOf allObjects]];
        for (int y=0; y<[enumerator count]; y++) {
            AvailableCharacteristic *tmpcharacteristic = [enumerator objectAtIndex:y];
            [tmp addObject:tmpcharacteristic.name];
            
        }
        [tmp sortUsingSelector:@selector(compare:)];
        [subchar addObject:tmp];
        
        
    }
    
    //set arrays
    self.SuperCharacteristics = superchar;
    self.Characteristics = subchar;

    
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
