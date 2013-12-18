//
//  SmartSourceFunctions.h
//  SmartSource
//
//  Created by Lorenz on 26.08.13.
//
//

#import <Foundation/Foundation.h>

@interface SmartSourceFunctions : NSObject
+ (NSString *)getHighMediumLowStringForFloatValue:(CGFloat)value;
+ (UIColor *)getColorForFloatRatingValue:(CGFloat)value;
+ (UIColor *)getColorForStringRatingValue:(NSString *)stringValue;
+ (NSString *)getSmallHighMediumLowStringForFloatValue:(CGFloat)value;
+ (NSString *)getOutIndCoreStringForWeightedAverageValue:(CGFloat)weightedAverage;
+ (UIImage *)getImageForWeightedAverageValue:(CGFloat)weightedAverage;
+ (NSString *)getHighMediumLowStringForIntValue:(NSInteger)value;
+ (UIColor *)getColorForStringClassificationValue:(NSString *)stringValue;

+ (BOOL)deviceRunsiOS7;
@end
