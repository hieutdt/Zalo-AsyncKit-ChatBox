//
//  StringHelper.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringHelper : NSObject

+ (NSString *)standardizeString:(NSString*)string;

+ (NSString *)getShortName:(NSString *)name;

+ (NSString *)randomString:(unsigned int)lenght;

@end

NS_ASSUME_NONNULL_END
