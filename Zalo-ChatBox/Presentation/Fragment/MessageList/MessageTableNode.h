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

@interface MessageTableNode : ASDisplayNode

- (void)setMessages:(NSArray<Message *> *)messages;

- (void)reloadData;

- (void)scrollToBottom;

@end

NS_ASSUME_NONNULL_END
