//
//  VeraRomanTextField.m
//  SmartSource
//
//  Created by Lorenz on 28.08.13.
//
//

#import "VeraRomanTextField.h"

@implementation VeraRomanTextField

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

- (VeraRomanTextField *)copy
{
    VeraRomanTextField *textView = [[VeraRomanTextField alloc] initWithFrame:self.frame];
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
