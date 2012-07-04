//
//  SettingsTableViewControllerViewController.m
//  SmartSource
//
//  Created by Lorenz on 02.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsTableViewControllerViewController.h"
#import "CharacteristicsTableViewController.h"

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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"loginData"] == nil) {
        [defaults setObject:[NSArray arrayWithObjects:@"url", @"rtoermer", @"hundhund", nil] forKey:@"loginData"];
        [defaults synchronize];
        NSLog(@"saved");
    } else {
        NSLog(@"already there");
    }
    
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
    return 2;
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
    NSArray *headers = [NSArray arrayWithObjects:@"Code Beamer Data", @"Rating Characteristics", nil];
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
    } else {
        static NSString *CellIdentifier = @"menuSelection";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = @"Edit Rating Characteristics";
        return cell;
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 1) && (indexPath.row==0)) {
        [self performSegueWithIdentifier:@"editCharacteristics" sender:self];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[titles objectAtIndex:indexPath.row] message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    
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

//recieve login information from alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 0) && (![[[alertView textFieldAtIndex:0] text] isEqualToString:@""]))
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editCharacteristics"]) {
        CharacteristicsTableViewController *charVC = segue.destinationViewController;
        charVC.managedObjectContext = self.managedObjectContext;
    }
}

@end
