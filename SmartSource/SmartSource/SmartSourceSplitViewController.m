//
//  SmartSourceSplitViewController.m
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmartSourceSplitViewController.h"
#import "MenuUIViewController.h"
#import "DetailTableViewController.h"


@interface SmartSourceSplitViewController ()

@end

@implementation SmartSourceSplitViewController
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mainMenu"]) {
        UINavigationController *navigation = segue.destinationViewController;
        MenuUIViewController *menu = [navigation.viewControllers objectAtIndex:0];
        menu.managedObjectContext = self.managedObjectContext;
            
    }

}

@end
