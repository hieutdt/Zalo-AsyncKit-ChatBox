//
//  MessageTableNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@class MessageTableNode;

@protocol MessageTableNodeDelegate <NSObject>

- (void)tableNodeNeedLoadMoreData;

@end

@interface MessageTableNode : ASDisplayNode

@property (nonatomic, assign) id<MessageTableNodeDelegate> delegate;

- (void)setMessagesToTable:(NSArray<Message *> *)messages;

- (void)reloadData;

- (void)scrollToBottom;

- (void)updateMoreMessages:(NSArray<Message *> *)messages;

- (void)setFriendAvatarImage:(UIImage *)image;

- (void)setGradientColorCode:(int)gradientColorCode
                andShortName:(NSString *)shortName;

@end

NS_ASSUME_NONNULL_END
