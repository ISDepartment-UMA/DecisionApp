//
//  WeightSliderDelegate.h
//  SmartSource
//
//  Created by Lorenz on 14.11.13.
//
//

#import <Foundation/Foundation.h>

@protocol WeightSliderDelegate <NSObject>
- (void)saveValueForSlider:(id)slider;
@end
