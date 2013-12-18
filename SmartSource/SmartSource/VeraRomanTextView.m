//
//  VeraRomanTextView.m
//  SmartSource
//
//  Created by Lorenz on 23.08.13.
//
//

#import "VeraRomanTextView.h"

@implementation VeraRomanTextView

//change font
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"BitstreamVeraSans-Roman" size:self.font.pointSize];
}

//copy
- (VeraRomanTextView *)copy
{
    VeraRomanTextView *textView = [[VeraRomanTextView alloc] initWithFrame:self.frame];
    textView.text = self.text;
    textView.textColor = self.textColor;
    textView.autoresizingMask = self.autoresizingMask;
    textView.backgroundColor = self.backgroundColor;
    textView.textAlignment = self.textAlignment;
    textView.font = self.font;
    [textView setHidden:self.hidden];
    
    return textView;
}


@end
