//
//  SinglePhotoMessage.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "Message.h"
#import "PhotoMessageCellNode.h"
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface SinglePhotoMessage : Message

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGFloat ratio;


- (instancetype)initWithPhotoURL:(NSString *)url ratio:(CGFloat)ratio;

- (instancetype)initWithPhotoURL:(NSString *)url
                           ratio:(CGFloat)ratio
                     fromContact:(Contact *)fromContact
                       toContact:(Contact *)toContact
                       timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
