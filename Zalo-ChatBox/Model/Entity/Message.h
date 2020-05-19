//
//  Message.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *fromPhoneNumber;
@property (nonatomic, strong) NSString *toPhoneNumber;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) MessageStyle style;

- (instancetype)initWithMessage:(NSString *)message
                           from:(NSString *)fromPhoneNumber
                             to:(NSString *)toPhoneNumber
                      timestamp:(NSTimeInterval)timestamp
                          style:(MessageStyle)style;

@end

NS_ASSUME_NONNULL_END
