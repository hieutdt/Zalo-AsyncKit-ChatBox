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

typedef NS_ENUM(NSInteger, TextMessageGroupType) {
    TextMessageGroupTypeNull,
    TextMessageGroupTypeTop,
    TextMessageGroupTypeCenter,
    TextMessageGroupTypeBottom
};

@class MessageCellNode;

@interface TextMessage : Message

@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) BOOL showTail;
@property (nonatomic, assign) TextMessageGroupType groupType;

- (instancetype)initWithMessage:(NSString *)message;

- (instancetype)initWithMessage:(NSString *)message
                    fromContact:(Contact *)fromContact
                      toContact:(Contact *)toContact
                      timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
