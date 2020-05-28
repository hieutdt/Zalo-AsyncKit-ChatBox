//
//  Message.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Message.h"

@implementation Message

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass userInfo:(_Nullable id)userInfo {
    return [self initWithCellNodeClass:cellNodeClass
                              userInfo:userInfo
                           fromContact:nil
                             toContact:nil
                             timestamp:0];
}

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass
                             userInfo:(_Nullable id)userInfo
                          fromContact:(Contact *)fromContact
                            toContact:(Contact *)toContact
                            timestamp:(NSTimeInterval)ts {
    self = [super initWithCellNodeClass:cellNodeClass userInfo:userInfo];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _fromContact = fromContact;
        _toContact = toContact;
        _timestamp = ts;
        _showAvatar = NO;
    }
    return self;
}


@end
