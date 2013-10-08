//
//  EntypoButton.m
//  SmartSource
//
//  Created by Lorenz on 07.10.13.
//
//

#import "EntypoButton.h"

@implementation EntypoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//Entypo
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName:@"Entypo" size:self.titleLabel.font.pointSize];
}

@end
