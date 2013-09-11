//
//  SmartSourceFunctions.m
//  SmartSource
//
//  Created by Lorenz on 26.08.13.
//
//

#import "SmartSourceFunctions.h"

@implementation SmartSourceFunctions


+ (NSString *)getHighMediumLowStringForFloatValue:(CGFloat)value
{
    if (value < 1.67) {
        return @"LOW";
    } else if (value < 2.34) {
        return @"MEDIUM";
    } else if (value <= 3.0) {
        return @"HIGH";
    } else {
        return @"";
    }
}


+ (UIColor *)getColorForRatingValue:(NSInteger)value
{
    switch (value) {
        case 1:
            return [UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0];
        case 2:
            return [UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0];
        case 3:
            return [UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0];
        default:
            return nil;
    }

    
}


+ (NSString *)getHighMediumLowStringForIntValue:(NSInteger)value
{
    switch (value) {
        case 1:
            return @"LOW";
        case 2:
            return @"MEDIUM";
            
            break;
        case 3:
            return @"HIGH";
        default:
            return nil;
    }
}

@end
