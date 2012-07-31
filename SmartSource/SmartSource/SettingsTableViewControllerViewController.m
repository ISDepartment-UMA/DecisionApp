//
//  SettingsTableViewControllerViewController.m
//  SmartSource
//
//  Created by Lorenz on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewControllerViewController.h"
#import "CharacteristicsTableViewController.h"
#import "AlertView.h"
#import "AvailableCharacteristic+Factory.h"
#import "AvailableSuperCharacteristic+Factory.h"
#import "RatingTableViewViewController.h"
#import "Project+Factory.h"
#import "SuperCharacteristic+Factory.h"
#import "Characteristic+Factory.h"
#import "Component+Factory.h"

@interface SettingsTableViewControllerViewController ()


@end

@implementation SettingsTableViewControllerViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

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
    //show navigation bar
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [super viewDidUnload];

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *headers = [NSArray arrayWithObjects:@"Code Beamer Data", @"Rating Characteristics", @"Default Settings", nil];
    return [headers objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"information";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *loginData = [defaults objectForKey:@"loginData"];
        
        NSArray *titles = [NSArray arrayWithObjects:@"URL", @"Username", @"Password", nil];
        cell.textLabel.text = [titles objectAtIndex:indexPath.row];
        
        //don't show password in detail text label
        if (indexPath.row == 2) {
            NSString *password = [loginData objectAtIndex:2];
            NSString *dotpassword =@"";
            for (int i=1; i<password.length ; i++) {
                dotpassword = [dotpassword stringByAppendingString:@"●"];
            }
            cell.detailTextLabel.text = dotpassword;
        } else {
            cell.detailTextLabel.text = [loginData objectAtIndex:indexPath.row];
        }
        
        return cell;
        return cell;
    } else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"menuSelection";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = @"Edit Rating Characteristics";
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"menuSelection";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = @"Restore Default Settings";
        return cell;
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row==0)) {
        [self performSegueWithIdentifier:@"editCharacteristics" sender:self];
    } else if (indexPath.section == 2){
        
        //show allert that will ask for acknoledgement
        NSString *message = @"Do you really want to reset the settings to default?";
        AlertView * alert = [[AlertView alloc] initWithTitle:@"Reset" message:message delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        alert.identifier = @"reset";
        alert.alertViewStyle = UIAlertViewStyleDefault;
        
        [alert show];
        
    }
}

//change code beamer login information
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //show alert for selected login information with currently saved value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *loginData = [defaults objectForKey:@"loginData"];
    NSArray *titles = [NSArray arrayWithObjects:@"Code Beamer URL", @"Code Beamer Username", @"Code Beamer Password", nil];
    NSString *message = [[@"Please enter your new" stringByAppendingString:[titles objectAtIndex:indexPath.row]] stringByAppendingString:@"."];
    AlertView * alert = [[AlertView alloc] initWithTitle:[titles objectAtIndex:indexPath.row] message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.identifier = @"loginData";
    
    //if selected login information is the password, change text field style
    if (indexPath.row == 2) {
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        
    //otherwise, it's just text input
    } else {
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    
    //set text field to old value
    [[alert textFieldAtIndex:0] setText:[loginData objectAtIndex:indexPath.row]];
    [alert show];
    
}

//recieve information from alertview
- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //login information
    if ((buttonIndex == 0) && ([alertView.identifier isEqualToString:@"loginData"]) && (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]))
    {
        //save returned value either as code beamer url...
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *loginData = [[defaults objectForKey:@"loginData"] mutableCopy];
        if ([alertView.title isEqualToString:@"Code Beamer URL"]) {
            [loginData replaceObjectAtIndex:0 withObject:[[alertView textFieldAtIndex:0] text]];
            
        //...username...
        } else if ([alertView.title isEqualToString:@"Code Beamer Username"]) {
            [loginData replaceObjectAtIndex:1 withObject:[[alertView textFieldAtIndex:0] text]];
            
        //...or password.
        } else if ([alertView.title isEqualToString:@"Code Beamer Password"]) {
            [loginData replaceObjectAtIndex:2 withObject:[[alertView textFieldAtIndex:0] text]];
        }
        
        //save defaults
        [defaults setObject:[loginData copy] forKey:@"loginData"];
        [defaults synchronize];
        [self.tableView reloadData];
    }
    
    
    //restore defaults
    if (([alertView.identifier isEqualToString:@"reset"]) && (buttonIndex == 0)) {
        
        
        //delete all supercharacteristics
        NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"AvailableSuperCharacteristic"];
        NSSortDescriptor *sortDescription = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        request1.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSError *error = nil;
        NSArray *matches1 = [self.managedObjectContext executeFetchRequest:request1 error:&error];
        
        for (int i=0; i<[matches1 count]; i++) {
            //delete supercharacteristic, cascade will delete all characteristics that belong to it
            [self.managedObjectContext deleteObject:[matches1 objectAtIndex:i]];
        }
        
        //delete all projects
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
        request2.sortDescriptors = [NSArray arrayWithObject:sortDescription];
        NSArray *matches2 = [self.managedObjectContext executeFetchRequest:request2 error:&error];
        
        for (int i=0; i<[matches2 count]; i++) {
            //delete supercharacteristic, cascade will delete all characteristics that belong to it
            [self.managedObjectContext deleteObject:[matches2 objectAtIndex:i]];
        }
        
        //insert root rating characteristics
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
        [AvailableSuperCharacteristic addNewAvailableSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
        
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Software Object Communication" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication of Requirements" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Communication among Developers" toSuperCharacteristic:@"Communication Complexity" toManagedObjectContext:self.managedObjectContext];
        
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Business Process Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Functional Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
        [AvailableCharacteristic addNewAvailableCharacteristic:@"Technical Specifity" toSuperCharacteristic:@"Knowledge Specifity" toManagedObjectContext:self.managedObjectContext];
        
        
        //reset default loginData
        [NSUserDefaults resetStandardUserDefaults];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSArray arrayWithObjects:@"http://79.125.4.182/remote-api", @"rtoermer", @"hundhund", nil] forKey:@"loginData"];
        [defaults synchronize];
        
        //save context
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.tableView reloadData];
        
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editCharacteristics"]) {
        CharacteristicsTableViewController *charVC = segue.destinationViewController;
        charVC.managedObjectContext = self.managedObjectContext;
    }
}

@end
