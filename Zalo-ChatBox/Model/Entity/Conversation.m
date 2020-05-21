//
//  Conversation.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "Conversation.h"

@interface Conversation ()

@end

@implementation Conversation

- (instancetype)initWithPersonA:(Contact *)personA
                        personB:(Contact *)personB
                       messages:(NSArray<Message *> *)messages {
    self = [super init];
    if (self) {
        _identifier = [[NSUUID UUID] UUIDString];
        _personA = personA;
        _personB = personB;
        _messages = [NSMutableArray arrayWithArray:messages];
    }
    return self;
}

- (BOOL)isConversationOf:(Contact *)personA
              andContact:(Contact *)personB {
    return (personA.phoneNumber == _personA.phoneNumber && personB.phoneNumber == _personB.phoneNumber) ||
    (personA.phoneNumber == _personB.phoneNumber && personB.phoneNumber == _personA.phoneNumber);
}

@end
