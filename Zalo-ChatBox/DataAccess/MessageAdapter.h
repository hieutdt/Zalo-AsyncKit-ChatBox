//
//  MessageAdapter.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Conversation.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageAdapter : NSObject

+ (instancetype)instance;

- (void)loadMessagesOfConversation:(Conversation *)conversation
                          loadMore:(BOOL)loadMore
                 completionHandler:(void (^)(NSArray<Message *> *messages, NSError *error))completionHandler;

- (Conversation *)getConversationOfContact:(Contact *)contactA
                                andContact:(Contact *)contactB;

@end

NS_ASSUME_NONNULL_END
