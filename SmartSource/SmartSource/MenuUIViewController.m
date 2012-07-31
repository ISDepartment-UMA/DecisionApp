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
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;


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
	// Do any additional setup after loading the view.
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMaserViewFromCodeBeamer" object:nil];
    
}

- (IBAction)showRatedProjects:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMasterViewFromCoreData" object:nil];

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"settings"]) {
        SettingsTableViewControllerViewController *setVC = segue.destinationViewController;
        setVC.managedObjectContext = self.managedObjectContext;
    }
    if ([segue.identifier isEqualToString:@"help"]) {
        ClassificationExplanationViewController *dest = segue.destinationViewController;
        dest.managedObjectContext = self.managedObjectContext;
        
    }
}


@end
