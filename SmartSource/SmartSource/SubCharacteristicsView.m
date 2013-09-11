//
//  SubCharacteristicsView.m
//  SmartSource
//
//  Created by Lorenz on 19.08.13.
//
//

#import "SubCharacteristicsView.h"
#import "VeraRomanLabel.h"

@implementation SubCharacteristicsView
@synthesize characteristicsSubView = _characteristicsSubView;
@synthesize ratingSubView = _ratingSubView;
@synthesize averageDescriptionLabel = _averageDescriptionLabel;
@synthesize averageValueLabel = _averageValueLabel;
@synthesize weightLabel = _weightLabel;
@synthesize weightedAverageLabel = _weightedAverageLabel;
@synthesize characteristicsNameLabel = _characteristicsNameLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setCharacteristics:(NSArray *)chars width:(CGFloat)widthOfView average:(CGFloat)average weight:(CGFloat)weight andWeightedAverage:(CGFloat) weightedAverage
{
    

    CGFloat heightOfExpansionView = (80 + ([[chars objectAtIndex:0] count] * 30));
    
    if (heightOfExpansionView < 170) {
        heightOfExpansionView = 170;
    }
    
    //build view that shouws subcharacteristics
    [self setFrame:CGRectMake(49, 49, widthOfView, heightOfExpansionView)];
    
    NSArray *subCharacteristicsValues = [chars objectAtIndex:1];
    NSArray *subCharacteristicsUsed = [chars objectAtIndex:0];
    
    
    //for every subcharacteristic
    for (int i=0; i<[subCharacteristicsUsed count]; i++) {
        
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
        if (value == 1) {
            [characteristicsRatingLabel setText:@"LOW"];
            [characteristicsRatingLabel setTextColor:[UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0]];
        } else if (value == 2) {
            [characteristicsRatingLabel setText:@"MEDIUM"];
            [characteristicsRatingLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0]];
        } else if (value == 3) {
            [characteristicsRatingLabel setText:@"HIGH"];
            [characteristicsRatingLabel setTextColor:[UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0]];
        }
        [self.ratingSubView addSubview:characteristicsRatingLabel];
    }
    
    //remove templates from view
    [self.characteristicsNameLabel removeFromSuperview];
    [self.characteristicsValueLabel removeFromSuperview];
    
    //set average
    //set evaluation label - high, medium low
    if (average < 1.67) {
        [self.averageDescriptionLabel setText:@"LOW"];
        [self.averageDescriptionLabel setTextColor:[UIColor colorWithRed:0.13 green:1.0 blue:0.45 alpha:1.0]];
    } else if (average < 2.34) {
        [self.averageDescriptionLabel setText:@"MEDIUM"];
        [self.averageDescriptionLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:0.52 alpha:1.0]];
    } else if (average <= 3.0) {
        [self.averageDescriptionLabel setText:@"HIGH"];
        [self.averageDescriptionLabel setTextColor:[UIColor colorWithRed:1.0 green:0.56 blue:0.56 alpha:1.0]];
    }
    
    //set average label
    [self.averageValueLabel setText:[NSString stringWithFormat:@"%.1f", average]];
    [self.scaleView setValue:average];
    
    //set weight
    [self.weightLabel setText:[[NSString stringWithFormat:@"%.f", (weight * 100)] stringByAppendingString:@"%"]];
    
    //set weighted average
    [self.weightedAverageLabel setText:[NSString stringWithFormat:@"%.1f", weightedAverage]];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
