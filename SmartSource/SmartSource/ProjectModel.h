//
//  ProjectModel.h
//  SmartSource
//
//  Created by Lorenz on 18.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "Component+Factory.h"
#import "Project+Factory.h"

@interface ProjectModel : Model

//initializers
- (ProjectModel *)initWithProjectID:(NSString *)projectID;
- (ProjectModel *)initWithProjectID:(NSString *)idOfProject useSoda:(BOOL)useSoda;

//getters and setters
- (Project *)getProjectObject;
- (NSArray *)arrayWithComponents;
- (NSArray *)getProjectInfoArray;
- (NSString *)getProjectID;
- (NSString *)getProjectName;
- (NSInteger)numberOfComponents;
- (Component *)getComponentObjectForID:(NSString *)componentID;
- (NSArray *)getSuperCharacteristics;

//completeness
- (BOOL)ratingIsComplete;

//main menu
- (BOOL)ratingCharacteristicsHaveBeenAdded;
- (BOOL)ratingCharacteristicsHaveBeenDeleted;
- (ProjectModel *)updateCoreDataBaseForProjectID:(NSString *)projectID;

//rating screen
- (void)saveWeightValue:(CGFloat)value forSuperCharacteristicWithName:(NSString *)superCharacteristicName;
- (BOOL)getProjectHasBeenWeighted;
- (void)setProjectHasBeenWeightedTrue;

//results
- (NSArray *)calculateResults;
- (NSArray *)getColumnsForDecisionTable;
- (NSArray *)getComponentsForCategory:(NSString *)category;
- (BOOL)uploadPdfToCollaborationPlatformNewCreationNecessary:(BOOL)necessary;
- (NSString *)createReportPdfAndReturnPathPrinterFriendly:(BOOL)printerFriendly;

//SODA
- (void)downloadAllRequirementsForProject;


@end
