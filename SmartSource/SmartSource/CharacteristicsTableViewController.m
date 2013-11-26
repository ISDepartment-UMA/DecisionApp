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
#import "SmartSourceAppDelegate.h"

@interface CharacteristicsTableViewController ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, strong) NSArray *SuperCharacteristics;
@property (nonatomic, strong) NSArray *Characteristics;


@end

@implementation CharacteristicsTableViewController
@synthesize SuperCharacteristics = _SuperCharacteristics;
@synthesize Characteristics = _Characteristics;
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
    
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;

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
    alert.identifier = @"insert";
    [alert show];
}

- (void)addCharacteristic:(UIButton *)sender
{
    //show allert that will ask for name of new characteristic
    NSString *message = @"Please enter the name for your new Characteristic!";
    AlertView * alert = [[AlertView alloc] initWithTitle:@"Characteristic" message:message delegate:self cancelButtonTitle:@"Insert" otherButtonTitles:@"Cancel", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    alert.objectToPass = [self.SuperCharacteristics objectAtIndex:[self.tableView indexPathForCell:cell].section-1];
    alert.identifier = @"insert";
    [alert show];
}

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{ 
    
    
    //response from alert to insert new characteristic
    //get context
    SmartSourceAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    if ([alertView.identifier isEqualToString:@"insert"]) {
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
            
            NSString *superCharacteristicName = (NSString *)alertView.objectToPass;
            //then insert the new characteristic
            [AvailableCharacteristic addNewAvailableCharacteristic:[[alertView textFieldAtIndex:0] text] toSuperCharacteristic:superCharacteristicName toManagedObjectContext:self.managedObjectContext];
            
            //save context
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            [self getRatingCharacteristics];
            [self.tableView reloadData];
            
        }
        
    //response from alert to delete characteristic
        
        
    } else if ([alertView.identifier isEqualToString:@"delete"]) {
        
        //if delete button was pressed
        if (buttonIndex == 0) {
            
            UITableViewCell *cell = (UITableViewCell *)alertView.objectToPass;
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            NSFetchRequest *request;
            
            
            //characteristic to delete is supercharacteristic
            if (indexPath.row == 0) {
                 request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
            } else {
                 request = [NSFetchRequest fetchRequestWithEntityName:@"AvailableCharacteristic"];
            }
            //look for 
            request.predicate = [NSPredicate predicateWithFormat:@"name =%@", alertView.title];
            NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
            request.sortDescriptors = [NSArray arrayWithObject:sortDescription];
            NSError *error = nil;
            NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            //delete characteristic -- if it's a supercharacteristic, cascade will delete all characteristics that belong to it
            [self.managedObjectContext deleteObject:[matches objectAtIndex:0]];
            
            //save context
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self getRatingCharacteristics];
            [self.tableView reloadData];        
        }
        
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
            
            [cell setAccessoryView:[self buildDeleteButton]];
            cell.accessoryView.userInteractionEnabled = YES;

            return cell;
        
        //beginning with the second row of each section, show the subcharacteristics
        } else if (indexPath.row < [[self.Characteristics objectAtIndex:indexPath.section-1] count]+1) {
            
            //return cell of subcharacteristic
            //get cell
            static NSString *CellIdentifier = @"CharacteristicCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            //add label
            cell.textLabel.text = [[self.Characteristics objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row-1];
            
            [cell setAccessoryView:[self buildDeleteButton]];
            cell.accessoryView.userInteractionEnabled = YES;
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

- (UIButton *)buildDeleteButton
{
    UIImage *normal = [UIImage imageNamed:@"delete.png"];
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(915, 22, 34, 33)];
    [deleteButton setImage:normal forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(eraseCharacteristic:) forControlEvents:UIControlEventTouchUpInside];
    
    return deleteButton;
}

- (void)eraseCharacteristic:(UIButton *)sender
{
    //erase
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *characteristicType = @"Characteristic?";
    if (indexPath.row == 0) {
        characteristicType = @"Super Characteristic?";
    }

    

    
    //show allert that will ask for name of new characteristic
    NSString *message = [@"Do you really want to delete this " stringByAppendingString:characteristicType];
    AlertView * alert = [[AlertView alloc] initWithTitle:cell.textLabel.text message:message delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
    alert.objectToPass = cell;
    alert.identifier = @"delete";
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    [alert show];
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