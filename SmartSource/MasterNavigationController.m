//
//  MasterNavigationController.m
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterNavigationController.h"
#import "ComponentsTableViewController.h"
#import "RatingTableViewViewController.h"


@interface MasterNavigationController ()

@end

@implementation MasterNavigationController

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
    return YES;
}



// makes sure that the detail navigation controller returns to the detailtableviewcontroller when 
// user returns from components selection back to project selection
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	if([[self.viewControllers lastObject] class] == [ComponentsTableViewController class]){
        
        UINavigationController *navigation = [self.splitViewController.viewControllers objectAtIndex:1];
        if ([[navigation.visibleViewController class] isSubclassOfClass:[RatingTableViewViewController class]]) {
            [navigation popViewControllerAnimated:YES];
        }
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 1.00];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                               forView:self.view cache:NO];
        
		UIViewController *viewController = [super popViewControllerAnimated:NO];
        
		[UIView commitAnimations];
        
		return viewController;
    } else {
		return [super popViewControllerAnimated:animated];
	}
    
}

@end
