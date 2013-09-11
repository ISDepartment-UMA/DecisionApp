//
//  ButtonExternalBackground.h
//  SmartSource
//
//  Created by Lorenz on 16.08.13.
//
//

#import <UIKit/UIKit.h>

@interface ButtonExternalBackground : UIButton

@property (strong, nonatomic) UIView *viewToChangeIfSelected;
@property (strong, nonatomic) UIColor *colorToUseIfSelected;

@end
