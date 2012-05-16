//
//  DetailUIViewController.m
//  SplitView
//
//  Created by Lorenz on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailUIViewController.h"

@interface DetailUIViewController ()
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@end


@implementation DetailUIViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize textLabel = _textLabel;


//set textlabel
- (void)setTextLabelto:(NSString *)text
{
    self.textLabel.text = text;
}


//button dance

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)viewDidUnload
{
    [self setTextLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end