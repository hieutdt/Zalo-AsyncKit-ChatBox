//
//  TextMessage.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@class MessageCellNode;

@interface TextMessage : Message

@property (nonatomic, strong) NSString *message;

- (instancetype)initWithMessage:(NSString *)message;

- (instancetype)initWithMessage:(NSString *)message
           fromOwnerPhoneNumber:(NSString *)ownerPhoneNumber
                  toPhoneNumber:(NSString *)toPhoneNumber
                      timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
