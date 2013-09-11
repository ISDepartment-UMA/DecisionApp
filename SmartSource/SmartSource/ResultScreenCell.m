//
//  ResultScreenCell.m
//  SmartSource
//
//  Created by Lorenz on 13.08.13.
//
//

#import "ResultScreenCell.h"

@interface ResultScreenCell ()
@property (nonatomic, strong) UIColor *previousColor;
@end
@implementation ResultScreenCell
@synthesize previousColor = _previousColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *backGroundView = [self.contentView viewWithTag:20];
    self.previousColor = backGroundView.backgroundColor;
    [backGroundView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.58 blue:0.0 alpha:1.0]];
    UIImageView *imageArrow = (UIImageView *)[backGroundView viewWithTag:11];
    [imageArrow setImage:[UIImage imageNamed:@"evaluation_pfeil_touched.png"]];
    [super touchesBegan:touches withEvent:event];
   
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *backGroundView = [self.contentView viewWithTag:20];
    UIColor *colorToSet = self.previousColor;
    self.previousColor = backGroundView.backgroundColor;
    [backGroundView setBackgroundColor:colorToSet];
    UIImageView *imageArrow = (UIImageView *)[backGroundView viewWithTag:11];
    [imageArrow setImage:[UIImage imageNamed:@"evaluation_pfeil.png"]];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *backGroundView = [self.contentView viewWithTag:20];
    UIColor *colorToSet = self.previousColor;
    self.previousColor = backGroundView.backgroundColor;
    [backGroundView setBackgroundColor:colorToSet];
    UIImageView *imageArrow = (UIImageView *)[backGroundView viewWithTag:11];
    [imageArrow setImage:[UIImage imageNamed:@"evaluation_pfeil.png"]];
    [super touchesCancelled:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
