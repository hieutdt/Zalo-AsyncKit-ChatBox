//
//  MessageInputView.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/29/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MessageInputView;

@protocol MessageInputViewDelegate <NSObject>

- (void)messageInputViewDidBeginEditing:(MessageInputView *)inputView;

- (void)messageInputViewDidEndEditing:(MessageInputView *)inputView;

- (void)messageInputViewSendButtonTapped:(MessageInputView *)inputView
                         withMessageText:(NSString *)messageText;

@end

@interface MessageInputView : UIView

@property (nonatomic, assign) id<MessageInputViewDelegate> delegate;

- (void)endEditing;

@end

NS_ASSUME_NONNULL_END
