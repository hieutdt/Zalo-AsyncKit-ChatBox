//
//  SinglePhotoMessage.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "SinglePhotoMessage.h"

@interface SinglePhotoMessage ()

@end

@implementation SinglePhotoMessage

- (instancetype)init {
    return [self initWithPhotoURL:@"" ratio:1 fromContact:nil toContact:nil timestamp:0];
}

- (instancetype)initWithPhotoURL:(NSString *)url ratio:(CGFloat)ratio {
    return [self initWithPhotoURL:url
                            ratio:ratio
                      fromContact:nil
                        toContact:nil
                        timestamp:0];
}

- (instancetype)initWithPhotoURL:(NSString *)url
                           ratio:(CGFloat)ratio
                     fromContact:(Contact *)fromContact
                       toContact:(Contact *)toContact
                       timestamp:(NSTimeInterval)ts {
    self = [super initWithCellNodeClass:[PhotoMessageCellNode class]
                               userInfo:nil
                            fromContact:fromContact
                              toContact:toContact
                              timestamp:ts];
    if (self) {
        _imageURL = [NSURL URLWithString:url];
        _ratio = ratio;
    }
    return self;
}

@end
