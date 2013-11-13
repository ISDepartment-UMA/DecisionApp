//
//  ProjectPlatformModelDelegate.h
//  SmartSource
//
//  Created by Lorenz on 09.11.13.
//
//

#import <Foundation/Foundation.h>

@protocol ProjectPlatformModelDelegate <NSObject>
- (void)projectArrayDidChange:(NSArray *)availableProjects;
- (BOOL)projectPlatformModelShouldKeepRetryingConnection;
@end
