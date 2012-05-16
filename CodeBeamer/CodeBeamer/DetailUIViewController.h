//
//  DetailUIViewController.h
//  SplitView
//
//  Created by Lorenz on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface DetailUIViewController : UIViewController <SplitViewBarButtonItemPresenter>
- (void)setTextLabelto:(NSString *)text;

@end
