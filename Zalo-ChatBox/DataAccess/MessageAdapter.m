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

#import "TextMessage.h"
#import "SinglePhotoMessage.h"
#import "GroupPhotoMessage.h"

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
        
        NSArray<Message *> *messages = [self generateRandomMessageForConversation:conversation
                                                                 numberOfMessages:numberOfMessages
                                                                           atTime:ts - 3600
                                                                           toTime:ts
                                                                     fromTextFile:@"message_data"
                                                                    photoUrlsFile:@"photo_data"];
        
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

#pragma mark - GenerateData

- (NSArray<Message *> *)generateRandomMessageForConversation:(Conversation *)conversation
                                            numberOfMessages:(int)numberOfMessages
                                                      atTime:(NSTimeInterval)fromTs
                                                      toTime:(NSTimeInterval)toTs
                                                fromTextFile:(NSString *)textFilePath
                                               photoUrlsFile:(NSString *)imageFilePath {
    if (numberOfMessages <= 0 || !conversation)
        return nil;
    
    NSArray<NSString *> *texts = [self stringsFromFile:textFilePath];
    NSArray<NSString *> *photos = [self stringsFromFile:imageFilePath];
    
    NSMutableArray<Message *> *messages = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numberOfMessages; i++) {
        Message *mess = nil;
        
        int type = RAND_FROM_TO(0, 7);
        if (type == 0) {
            int index = RAND_FROM_TO(0, (int)photos.count - 1);
            mess = [[SinglePhotoMessage alloc] initWithPhotoURL:photos[index] ratio:1];
            
        } else if (type == 1) {
            int numberOfPhotos = RAND_FROM_TO(3, 6);
            NSMutableArray *urls = [[NSMutableArray alloc] init];
            for (int j = 0; j < numberOfPhotos; j++) {
                int index = RAND_FROM_TO(0, (int)photos.count - 1);
                [urls addObject:photos[index]];
            }
            
            mess = [[GroupPhotoMessage alloc] initWithPhotoUrls:urls];
            
        } else {
            int index = RAND_FROM_TO(0, (int)texts.count - 1);
            mess = [[TextMessage alloc] initWithMessage:texts[index]];
        }
        
        int sender = RAND_FROM_TO(0, 1);
        if (sender == 0) {
            mess.fromContact = conversation.personA;
            mess.toContact = conversation.personB;
        } else {
            mess.fromContact = conversation.personB;
            mess.toContact = conversation.personA;
        }
        
        NSInteger ts = RAND_FROM_TO(fromTs, toTs);
        mess.timestamp = ts;
        
        [messages addObject:mess];
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortedArray = [messages sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return sortedArray;
}

- (NSArray<NSString *> *)stringsFromFile:(NSString *)filePath {
    NSString *path = [[NSBundle mainBundle] pathForResource:filePath
                                                     ofType:@"txt"];
    NSString *fileContent = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    NSMutableArray<NSString *> *strings = [NSMutableArray arrayWithArray:[fileContent componentsSeparatedByString:@"\n"]];
    [strings removeObjectsInArray:@[@"", @" "]];
    
    return strings;
}

@end
