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

- (NSString *)getRandomStickerUrl {
    // Bé dúi sticker :]
    NSArray *stickerUrls = @[
        @"https://gamek.mediacdn.vn/133514250583805952/2020/3/25/photo-1-15851124865381840812328.jpg",
        @"https://gamek.mediacdn.vn/133514250583805952/2020/3/25/photo-1-15851124904181558989902.jpg",
        @"https://gamek.mediacdn.vn/133514250583805952/2020/3/25/photo-1-1585112494461239804713.jpg",
        @"https://gamek.mediacdn.vn/133514250583805952/2020/3/25/photo-1-15851125083671094172698.jpg",
        @"https://gamek.mediacdn.vn/133514250583805952/2020/3/25/photo-1-1585112527367491122786.jpg"
    ];
    
    NSInteger index = RAND_FROM_TO(0, stickerUrls.count - 1);
    return stickerUrls[index];
}

@end
