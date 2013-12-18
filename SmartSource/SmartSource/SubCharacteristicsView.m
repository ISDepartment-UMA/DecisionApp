//
//  SubCharacteristicsView.m
//  SmartSource
//
//  Created by Lorenz on 19.08.13.
//
//

#import "SubCharacteristicsView.h"
#import "VeraRomanLabel.h"
#import "SmartSourceFunctions.h"
#import "SmartSourceFunctions.h"

@implementation SubCharacteristicsView
@synthesize characteristicsSubView = _characteristicsSubView;
@synthesize ratingSubView = _ratingSubView;
@synthesize averageDescriptionLabel = _averageDescriptionLabel;
@synthesize averageValueLabel = _averageValueLabel;
@synthesize weightLabel = _weightLabel;
@synthesize weightedAverageLabel = _weightedAverageLabel;
@synthesize characteristicsNameLabel = _characteristicsNameLabel;



- (void)setCharacteristics:(NSArray *)chars width:(CGFloat)widthOfView average:(CGFloat)average weight:(CGFloat)weight andWeightedAverage:(CGFloat) weightedAverage
{
    //height of view depends on number of subcharacteristics, but is at least 170
    CGFloat heightOfExpansionView = (80 + ([[chars objectAtIndex:0] count] * 30));
    if (heightOfExpansionView < 170) {
        heightOfExpansionView = 170;
    }
    //build view that shouws subcharacteristics
    [self setFrame:CGRectMake(49, 49, widthOfView, heightOfExpansionView)];
    //subchar names and values
    NSArray *subCharacteristicsValues = [chars objectAtIndex:1];
    NSArray *subCharacteristicsUsed = [chars objectAtIndex:0];
    //for every subcharacteristic
    for (int i=0; i<[subCharacteristicsUsed count]; i++) {
        //get name and value
        NSString *subCharName = [subCharacteristicsUsed objectAtIndex:i];
        NSInteger value = [[subCharacteristicsValues objectAtIndex:i] integerValue];
        //build name label
        VeraRomanLabel *characteristicsNameLabel = [self.characteristicsNameLabel copy];
        [characteristicsNameLabel setFrame:CGRectMake(self.characteristicsNameLabel.frame.origin.x, (60 + 30*i), self.characteristicsNameLabel.frame.size.width, self.characteristicsNameLabel.frame.size.height)];
        [characteristicsNameLabel setText:subCharName];
        [self.characteristicsSubView addSubview:characteristicsNameLabel];
        //build rating label
        VeraRomanLabel *characteristicsRatingLabel = [self.characteristicsValueLabel copy];
        [characteristicsRatingLabel setFrame:CGRectMake(self.characteristicsNameLabel.frame.origin.x, (20 + 30*i), self.characteristicsNameLabel.frame.size.width, self.characteristicsNameLabel.frame.size.height)];
        //set evaluation label - high, medium low
        [characteristicsRatingLabel setText:[SmartSourceFunctions getHighMediumLowStringForIntValue:value]];
        [characteristicsRatingLabel setTextColor:[SmartSourceFunctions getColorForStringRatingValue:characteristicsRatingLabel.text]];
        [self.ratingSubView addSubview:characteristicsRatingLabel];
    }
    //remove templates from view
    [self.characteristicsNameLabel removeFromSuperview];
    [self.characteristicsValueLabel removeFromSuperview];
    //set average
    //set evaluation label - high, medium low
    [self.averageDescriptionLabel setText:[SmartSourceFunctions getHighMediumLowStringForFloatValue:average]];
    [self.averageDescriptionLabel setTextColor:[SmartSourceFunctions getColorForStringRatingValue:self.averageDescriptionLabel.text]];
    //set average label
    [self.averageValueLabel setText:[NSString stringWithFormat:@"%.1f", average]];
    [self.scaleView setValue:average];
    //set weight
    [self.weightLabel setText:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
    //set weighted average
    [self.weightedAverageLabel setText:[NSString stringWithFormat:@"%.1f", weightedAverage]];
}

@end
