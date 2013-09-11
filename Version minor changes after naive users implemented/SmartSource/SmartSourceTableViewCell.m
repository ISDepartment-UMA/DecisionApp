//
//  SmartSourceTableViewCell.m
//  SmartSource
//
//  Created by Lorenz on 31.07.13.
//
//

#import "SmartSourceTableViewCell.h"

@interface SmartSourceTableViewCell ()


@end

@implementation SmartSourceTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self.textLabel setFont:[UIFont fontWithName:@"Bitstream Vera" size:17.0]];
    [self.textLabel setTextColor:[UIColor whiteColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width, 20)];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [self insertSubview:blackView belowSubview:self.textLabel];
    
    
    /*
     //background color
     CGFloat red = (135/255);
     [self setBackgroundColor:[UIColor colorWithRed:red green:red blue:red alpha:1.0]];
     
     
     [self.textLabel setTextColor:[UIColor whiteColor]];
     */
    
    
    
    return self;
    
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
