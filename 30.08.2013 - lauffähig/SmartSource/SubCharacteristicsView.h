//
//  SubCharacteristicsView.h
//  SmartSource
//
//  Created by Lorenz on 19.08.13.
//
//

#import <UIKit/UIKit.h>
#import "ScaleView.h"


@interface SubCharacteristicsView : UIView

@property (nonatomic, strong) IBOutlet UIView *characteristicsSubView;
@property (nonatomic, strong) IBOutlet UIView *ratingSubView;
@property (nonatomic, strong) IBOutlet ScaleView *scaleView;
@property (nonatomic, strong) IBOutlet UILabel *averageDescriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *averageValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *weightLabel;
@property (nonatomic, strong) IBOutlet UILabel *weightedAverageLabel;

@property (nonatomic, strong) IBOutlet UILabel *characteristicsNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *characteristicsValueLabel;


- (void)setCharacteristics:(NSArray *)chars width:(CGFloat)widthOfView average:(CGFloat)average weight:(CGFloat)weight andWeightedAverage:(CGFloat) weightedAverage;


@end
