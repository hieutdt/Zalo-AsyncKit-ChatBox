//
//  MessageAdapter.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MessageAdapter.h"
#import "StringHelper.h"
#import "AppConsts.h"

static const int kLoadMoreCount = 20;

@interface MessageAdapter ()

@property (nonatomic, strong) NSMutableArray<Conversation *> *conversations;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end

@implementation MessageAdapter

+ (instancetype)instance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MessageAdapter alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _conversations = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("MessageAdapterSerialQueue", DISPATCH_QUEUE_SERIAL);
        _concurrentQueue = dispatch_queue_create("MessageAdapterConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)loadMessagesOfConversation:(Conversation *)conversation
                          loadMore:(BOOL)loadMore
                 completionHandler:(void (^)(NSArray<Message *> *messages, NSError *error))completionHandler {
    if (!loadMore && conversation.messages.count > 0 && completionHandler) {
        completionHandler(conversation.messages, nil);
        return;
    }
    
    __weak MessageAdapter *weakSelf = self;
    dispatch_async(_concurrentQueue, ^{
        int numberOfMessages = loadMore ? kLoadMoreCount : 50;
        NSTimeInterval ts = 0;
        if (conversation.messages.count > 0) {
            ts = conversation.messages[conversation.messages.count - 1].timestamp;
        } else {
            NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
            ts = timeInSeconds;
        }
        
        NSArray<Message *> *messages = [self generateRandomMessagesForConversation:conversation
                                                                  numberOfMessages:numberOfMessages
                                                                            atTime:ts - 3600
                                                                            toTime:ts];
        
        if (!loadMore && [weakSelf.conversations containsObject:conversation]) {
            conversation.messages = [NSMutableArray arrayWithArray:messages];
        }
        
        if (completionHandler) {
            completionHandler(messages, nil);
        }
    });
}

- (Conversation *)getConversationOfContact:(Contact *)contactA
                                andContact:(Contact *)contactB {
    for (NSInteger i = 0; i < _conversations.count; i++) {
        if ([_conversations[i] isConversationOf:contactA andContact:contactB]) {
            return _conversations[i];
        }
    }
    
    Conversation *conversation = [[Conversation alloc] initWithPersonA:contactA
                                                               personB:contactB
                                                              messages:nil];
    [_conversations addObject:conversation];
    return conversation;
}

- (NSArray<Message *> *)generateRandomMessagesForConversation:(Conversation *)conversation
                                             numberOfMessages:(int)numberOfMessages
                                                       atTime:(NSTimeInterval)fromTs
                                                       toTime:(NSTimeInterval)toTs {
    if (numberOfMessages <= 0 || !conversation)
        return nil;
    
    NSMutableArray<Message *> *messages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberOfMessages; i++) {
        Message *mess = [[Message alloc] init];
        
        int sender = RAND_FROM_TO(0, 1);
        if (sender == 0) {
            mess.fromPhoneNumber = conversation.personA.phoneNumber;
            mess.toPhoneNumber = conversation.personB.phoneNumber;
        } else {
            mess.fromPhoneNumber = conversation.personB.phoneNumber;
            mess.toPhoneNumber = conversation.personA.phoneNumber;
        }
        
        NSInteger ts = RAND_FROM_TO(fromTs, toTs);
        mess.timestamp = ts;
        
        unsigned int messLenght = RAND_FROM_TO(1, 100);
        mess.message = [StringHelper randomString:messLenght];
        
        [messages addObject:mess];
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedArray = [messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return sortedArray;
}

@end
