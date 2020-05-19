//
//  Message.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _message = [[NSString alloc] init];
        _fromPhoneNumber = [[NSString alloc] init];
        _toPhoneNumber = [[NSString alloc] init];
        _timestamp = 0;
        _style = MessageStyleText;
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
                           from:(NSString *)fromPhoneNumber
                             to:(NSString *)toPhoneNumber
                      timestamp:(NSTimeInterval)timestamp
                          style:(MessageStyle)style {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _message = message;
        _fromPhoneNumber = fromPhoneNumber;
        _toPhoneNumber = toPhoneNumber;
        _timestamp = timestamp;
        _style = style;
    }
    return self;
}

@end
