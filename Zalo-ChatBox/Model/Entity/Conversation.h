//
//  Conversation.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/21/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) Contact *personA;
@property (nonatomic, strong) Contact *personB;
@property (nonatomic, strong) NSMutableArray<Message *> *messages;

- (instancetype)initWithPersonA:(Contact *)personA
                        personB:(Contact *)personB
                       messages:(nullable NSArray<Message *> *)messages;

- (BOOL)isConversationOf:(Contact *)personA
              andContact:(Contact *)personB;

@end

NS_ASSUME_NONNULL_END
