//
//  EntypoLabel.m
//  SmartSource
//
//  Created by Lorenz on 05.09.13.
//
//

#import "EntypoLabel.h"

@implementation EntypoLabel

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
    self.font = [UIFont fontWithName:@"Entypo" size:self.font.pointSize];
}


@end
