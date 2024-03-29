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

+ (NSString *)getSmallHighMediumLowStringForFloatValue:(CGFloat)value
{
    if (value < 1.67) {
        return @"low";
    } else if (value < 2.34) {
        return @"medium";
    } else if (value <= 3.0) {
        return @"high";
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



+ (UIColor *)getColorForFloatRatingValue:(CGFloat)value
{
    if (value < 1.67) {
        return [UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0];
    } else if (value < 2.34) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0];
    } else if (value <= 3.0) {
        return [UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0];
    } else {
        return nil;
    }
}

+ (UIColor *)getColorForStringRatingValue:(NSString *)stringValue
{
    if ([stringValue isEqualToString:@"LOW"]) {
        return [UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0];
    } else if ([stringValue isEqualToString:@"MEDIUM"]) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0];
    } else if ([stringValue isEqualToString:@"HIGH"]) {
        return [UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0];
    } else {
        return nil;
    }
}

+ (UIColor *)getColorForStringClassificationValue:(NSString *)stringValue
{
    if ([stringValue isEqualToString:@"OUTSOURCING"]) {
        return [UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0];
    } else if ([stringValue isEqualToString:@"INDIFFERENT"]) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0];
    } else if ([stringValue isEqualToString:@"CORE"]) {
        return [UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0];
    } else {
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

+ (NSString *)getOutIndCoreStringForWeightedAverageValue:(CGFloat)weightedAverage
{
    if (weightedAverage < 1.67) {
        return @"OUTSOURCING";
    } else if (weightedAverage < 2.34) {
        return @"INDIFFERENT";
    } else if (weightedAverage <= 3.0) {
        return @"CORE";
    } else {
        return nil;
    }
}

+ (UIImage *)getImageForWeightedAverageValue:(CGFloat)weightedAverage
{
    if (weightedAverage < 1.67) {
        return [UIImage imageNamed:@"Result_Out.png"];
    } else if (weightedAverage < 2.34) {
        return [UIImage imageNamed:@"Result_Un.png"];
    } else if (weightedAverage <= 3.0) {
        return [UIImage imageNamed:@"Result_In.png"];
    } else {
        return nil;
    }
}

//iOS Versions
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
+ (BOOL)deviceRunsiOS7
{
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        return NO;
    } else {
        return YES;
    }
}

@end
