//
//  NSString+Encode.m
//  SmartSource
//
//  Created by Lorenz on 07.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (encode)
- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)self,
                                                                nil, (CFStringRef)@";/?:@&=$+{}<>,",CFStringConvertNSStringEncodingToEncoding(encoding));
    
}  

@end
