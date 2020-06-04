//
//  TextMessage.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TextMessage.h"
#import "TextMessageCellNode.h"

@interface TextMessage ()

@end

@implementation TextMessage

- (instancetype)init {
    return [self initWithMessage:@"" fromContact:nil toContact:nil timestamp:0];
}

- (instancetype)initWithMessage:(NSString *)message {
    return [self initWithMessage:message fromContact:nil toContact:nil timestamp:0];
}

- (instancetype)initWithMessage:(NSString *)message
                    fromContact:(Contact *)fromContact
                      toContact:(Contact *)toContact
                      timestamp:(NSTimeInterval)ts {
    self = [super initWithCellNodeClass:[TextMessageCellNode class]
                               userInfo:nil
                            fromContact:fromContact
                              toContact:toContact
                              timestamp:ts];
    if (self) {
        _message = message;
        _showTail = NO;
        _groupType = TextMessageGroupTypeNull;
    }
    return self;
}

@end
