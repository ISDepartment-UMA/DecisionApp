//
//  UploadCompleteHandler.h
//  SmartSource
//
//  Created by Lorenz on 30.10.13.
//
//

#import <Foundation/Foundation.h>

@protocol UploadCompleteHandler <NSObject>


- (void)uploadComplete;
- (void)uploadFailed;
//necessary in case upload is finished before view controller has even loaded completely
@property (nonatomic) BOOL ableToRespond;

@end
