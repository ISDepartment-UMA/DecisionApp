//
//  ClassificationModel.h
//  SmartSource
//
//  Created by Lorenz on 28.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Component+Factory.h"

@interface ClassificationModel : NSObject


@property (nonatomic, strong) NSArray *classification;

- (ClassificationModel *) initWithProjectID:(NSString *)projectID;
- (NSArray *)getProjectArray;
- (NSString *)getProjectID;
- (NSString *)getProjectName;
- (NSArray *)getComponentsForCategory:(NSString *)category;
- (NSArray *)getColumnsForDecisionTable;
- (Component *)getComponentForID:(NSString *)componentID;
- (NSDictionary *)getComponentInfoForID:(NSString *)componentID;
- (NSArray *)getCharsAndValuesArray:(NSString *)componentID;


@end
