//
//  Message.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/18/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConsts.h"
#import "CellNodeObject.h"
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message : CellNodeObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) Contact *fromContact;
@property (nonatomic, strong) Contact *toContact;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) BOOL showAvatar;

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass
                             userInfo:(_Nullable id)userInfo;

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass
                             userInfo:(_Nullable id)userInfo
                          fromContact:(Contact *)fromContact
                            toContact:(Contact *)toContact
                            timestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
