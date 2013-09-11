//
//  VeraRomanLabel.m
//  SmartSource
//
//  Created by Lorenz on 17.08.13.
//
//

#import "VeraRomanLabel.h"

@implementation VeraRomanLabel

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
    self.font = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:self.font.pointSize];
}

- (id)copy
{
    VeraRomanLabel *duplicateLabel = [[VeraRomanLabel alloc] initWithFrame:self.frame];
    duplicateLabel.text = self.text;
    duplicateLabel.textColor = self.textColor;
    duplicateLabel.autoresizingMask = self.autoresizingMask;
    duplicateLabel.backgroundColor = self.backgroundColor;
    duplicateLabel.textAlignment = self.textAlignment;
    duplicateLabel.font = self.font;
    duplicateLabel.numberOfLines = self.numberOfLines;
    duplicateLabel.lineBreakMode = self.lineBreakMode;
    [duplicateLabel setHidden:self.hidden];
    
    return duplicateLabel;
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
