//
//  MessageReactionNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/4/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MessageReactionNode;

@protocol MessageReactionNodeDelegate <NSObject>

@required
- (void)messageReactionNode:(MessageReactionNode *)reactionNode
      didSelectReactionType:(NSInteger)reactionType;

@end

@interface MessageReactionNode : ASDisplayNode

@property (nonatomic, assign) id<MessageReactionNodeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
