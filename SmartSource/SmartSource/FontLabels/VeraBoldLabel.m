//
//  VeraBoldLabel.m
//  SmartSource
//
//  Created by Lorenz on 17.08.13.
//
//

#import "VeraBoldLabel.h"

@implementation VeraBoldLabel


//set font
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"BitstreamVeraSans-Bold" size:self.font.pointSize];
}

//copy
- (id)copy
{
    VeraBoldLabel *duplicateLabel = [[VeraBoldLabel alloc] initWithFrame:self.frame];
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

@end
