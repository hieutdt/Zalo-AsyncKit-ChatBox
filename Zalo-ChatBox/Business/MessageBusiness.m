//
//  MessageBusiness.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageBusiness.h"
#import "MessageAdapter.h"

@interface MessageBusiness ()

@end

@implementation MessageBusiness


- (Conversation *)getConversationOfContact:(Contact *)contactA
                                andContact:(Contact *)contactB {
    return [[MessageAdapter instance] getConversationOfContact:contactA
                                                    andContact:contactB];
}

- (void)loadMessagesForConversation:(Conversation *)conversation
                           loadMore:(BOOL)loadMore
                  completionHandler:(void (^)(NSArray<Message *> *messages, NSError *error))completionHandler {
    if (!conversation)
        return;
    
    [[MessageAdapter instance] loadMessagesOfConversation:conversation
                                                 loadMore:loadMore
                                        completionHandler:completionHandler];
}



@end
