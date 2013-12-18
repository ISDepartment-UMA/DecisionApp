//
//  UIColor+SmartSourceColors.m
//  SmartSource
//
//  Created by Lorenz on 03.11.13.
//
//

#import "UIColor+SmartSourceColors.h"

@implementation UIColor (SmartSourceColors)


+ (UIColor *)colorOrange;
{
    return [UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0];
}

+ (UIColor *)colorLightOrange
{
    return [UIColor colorWithRed:0.99 green:0.80 blue:0.55 alpha:1.0];
}

+ (UIColor *)colorOrangeBackgroundChange
{
    return [UIColor colorWithRed:0.98 green:0.7 blue:0.25 alpha:1.0];
}

+ (UIColor *)colorLightGray
{
    return [UIColor colorWithRed:0.529 green:0.529 blue:0.529 alpha:1.0];
}

+ (UIColor *)colorDarkWhite
{
    return [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1.0];    
}


+ (UIColor *)colorDarkGray
{
    return [UIColor colorWithRed:0.251 green:0.251 blue:0.251 alpha:1.0];
}

@end
