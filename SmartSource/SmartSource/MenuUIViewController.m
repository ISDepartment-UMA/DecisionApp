//
//  MenuUIViewController.m
//  SmartSource
//
//  Created by Lorenz on 19.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MenuUIViewController.h"
#import "SettingsTableViewControllerViewController.h"
#import "SmartSourceMasterViewController.h"
#import "ClassificationExplanationViewController.h"
@interface MenuUIViewController ()



@end

@implementation MenuUIViewController
@synthesize detailScreen = _detailScreen;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Main Menu"];
    
    //check if user data has been entered correctly
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //no user data at all
    if ([defaults objectForKey:@"loginData"] == nil) {
        [self showLoginDataAlert];
        
    // empty username
    } else {
        NSArray *loginData = [defaults objectForKey:@"loginData"];
        if ([[loginData objectAtIndex:1] isEqualToString:@""]) {
            [self showLoginDataAlert];
        }
        
    }
    
}


//shows alert that tells user to enter logindata
- (void)showLoginDataAlert
{
    UIAlertView *disclaimerAgreedAlertView = [[UIAlertView alloc] initWithTitle:@"Code Beamer Connection"
                                                                        message:@"Your Code Beamer Data is required."
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"OK", nil];
    [disclaimerAgreedAlertView show];
    
}

//segue to settings once the alert has been closed
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"settings" sender:self];
    }
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)selectProjects:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.detailScreen getProjectsFromWebService];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsFromCodebeamer" object:nil];
    
}

- (IBAction)showRatedProjects:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.detailScreen getProjectsFromCoreData];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"LoadProjectsFromCoreData" object:nil];

    
}


@end
