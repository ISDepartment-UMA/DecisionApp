//
//  SodaCharacteristicCell.m
//  SmartSource
//
//  Created by Lorenz on 19.11.13.
//
//

#import "SodaCharacteristicCell.h"
#import "CharacteristicCellDelegate.h"
#import "SODAFunctions.h"

@interface SodaCharacteristicCell()
@property (nonatomic, strong) Characteristic *currentCharacteristic;
@property (nonatomic, weak) id<CharacteristicCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *speechBubbleArrowImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;
@property (strong, nonatomic) IBOutlet UIView *mainSubView;
@end

@implementation SodaCharacteristicCell
@synthesize speechBubbleArrowImageView = _speechBubbleArrowImageView;
@synthesize explanationLabel = _explanationLabel;

//main method that sets characteristc and delegate and modifies cell content accordingly
- (void)setCharacteristic:(Characteristic *)currentCharacteristic andDelegate:(id<CharacteristicCellDelegate>)delegate
{
    [super setCharacteristic:currentCharacteristic andDelegate:delegate];
    //explanation
    NSNumber *valueOfInterest = nil;
    NSString *explanation = @"";
    if ([currentCharacteristic.name isEqualToString:@"Autonomy of requirements within this component"]) {
        valueOfInterest = [self.delegate getValueForCohesion];
        explanation = [NSString stringWithFormat:@"SODA produced a cohesion value of %.1f for the graph of requirements related to this component.", [valueOfInterest floatValue]];
        valueOfInterest = [NSNumber numberWithFloat:(1-[valueOfInterest floatValue])];
    } else if ([currentCharacteristic.name isEqualToString:@"Number of inter-component requirements links"]) {
        valueOfInterest = [self.delegate getValueForCoupling];
        explanation = [NSString stringWithFormat:@"SODA produced a coupling value of %.1f for the graph of requirements related to this component.", [valueOfInterest floatValue]];
    }
    [self.explanationLabel setText:explanation];
    
    //position of arrow
    NSInteger integerOfInterest = [[SODAFunctions get123ValueForLinearValue:[valueOfInterest floatValue]] integerValue];
    CGFloat xTargetOfArray;
    switch (integerOfInterest) {
        case 1:
            xTargetOfArray = self.mainSubView.frame.size.width - 392;
            break;
        case 2:
            xTargetOfArray = self.mainSubView.frame.size.width - 266;
            break;
        case 3:
            xTargetOfArray = self.mainSubView.frame.size.width - 142;
            break;
        default:
            xTargetOfArray = 0;
            break;
    }
    CGRect arrowFrame = self.speechBubbleArrowImageView.frame;
    [self.speechBubbleArrowImageView setFrame:CGRectMake(xTargetOfArray, arrowFrame.origin.y, arrowFrame.size.width, arrowFrame.size.height)];
}

@end
