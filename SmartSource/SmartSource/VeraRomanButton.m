//
//  VeraRomanButton.m
//  SmartSource
//
//  Created by Lorenz on 23.08.13.
//
//

#import "VeraRomanButton.h"

@implementation VeraRomanButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:self.titleLabel.font.pointSize];
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
