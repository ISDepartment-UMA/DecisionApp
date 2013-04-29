//
//  ProjectModel.h
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import <Foundation/Foundation.h>

@interface ProjectModel : NSObject


- (ProjectModel *)initWithProjectID:(NSString *)projectID;
- (NSArray *)arrayWithComponents;
- (BOOL)ratingIsComplete;
- (NSInteger)numberOfComponents;
- (NSString *) getID;



@end
