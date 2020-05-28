//
//  GroupPhotoMessage.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"
#import "GroupPhotoMessageCellNode.h"
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupPhotoMessage : Message

@property (nonatomic, strong) NSArray<NSString *> *urls;

- (instancetype)initWithPhotoUrls:(NSArray<NSString *> *)urls;

- (instancetype)initWithPhotoUrls:(NSArray<NSString *> *)urls
                      fromContact:(Contact *)fromContact
                        toContact:(Contact *)toContact
                        timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
