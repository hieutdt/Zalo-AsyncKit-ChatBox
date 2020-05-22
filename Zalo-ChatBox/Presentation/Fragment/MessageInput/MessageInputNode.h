//
//  MessageInputNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MessageInputNodeDelegate <NSObject>

- (void)sendMessage:(NSString *)message;

@end

@interface MessageInputNode : ASDisplayNode

@property (nonatomic, assign) id<MessageInputNodeDelegate> delegate;

- (void)endEditing;

@end

NS_ASSUME_NONNULL_END
