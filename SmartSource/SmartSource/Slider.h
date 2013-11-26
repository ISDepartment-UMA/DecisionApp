//
//  Slider.h
//  SmartSource
//
//  Created by Lorenz on 22.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeightSliderDelegate.h"


@interface Slider : UISlider

- (void)setSliderDelegate:(id<WeightSliderDelegate>)sliderDelegate;

@end
