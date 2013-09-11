//
//  SmartSourceSplitViewController.m
//  SmartSource
//
//  Created by Lorenz on 27.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SmartSourceSplitViewController.h"
#import "MainMenuViewController.h"
#import "RatingTableViewViewController.h"
#import "WeightSuperCharacteristicsViewController.h"


@interface SmartSourceSplitViewController ()

@end

@implementation SmartSourceSplitViewController
@synthesize barButtonItem = _barButtonItem;
@synthesize masterPopoverController = _masterPopoverController;



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
    UINavigationController *navigation = (UINavigationController *)[self.viewControllers lastObject];
    self.delegate = (RatingTableViewViewController *)[navigation.viewControllers lastObject];
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
        UINavigationController *navigationC = (UINavigationController *)segue.destinationViewController;
        MainMenuViewController *mainMenuC = (MainMenuViewController *)[navigationC.viewControllers objectAtIndex:0];
        [mainMenuC setRatingScreen:sender];
    } else if ([segue.identifier isEqualToString:@"weightSuperChars"]){
        
        WeightSuperCharacteristicsViewController *wSCVC = (WeightSuperCharacteristicsViewController *)segue.destinationViewController;
        RatingTableViewViewController *rtvc = [[[self.viewControllers lastObject] viewControllers] lastObject];
        [wSCVC setRatingDelegate:rtvc];
    }
}








@end
