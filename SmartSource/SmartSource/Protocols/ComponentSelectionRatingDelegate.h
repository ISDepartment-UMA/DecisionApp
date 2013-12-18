//
//  ComponentSelectionRatingDelegate.h
//  SmartSource
//
//  Created by Lorenz on 06.12.13.
//
//

#import <Foundation/Foundation.h>
#import "Component.h"

@protocol ComponentSelectionRatingDelegate <NSObject>

- (void)masterViewIsThere;
- (void)masterViewIsNotThere;
- (NSArray *)getAvailableComponents;
- (Component *)getSelectedComponent;
- (void)setComponent:(Component *)component;

@property (nonatomic) BOOL componentRatingIsComplete;
@property (nonatomic) BOOL weightingIsComplete;
@end
