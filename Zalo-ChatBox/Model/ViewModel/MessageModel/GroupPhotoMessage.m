//
//  GroupPhotoMessage.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/28/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "GroupPhotoMessage.h"

@implementation GroupPhotoMessage

- (instancetype)init {
    return [self initWithPhotoUrls:@[]
                       fromContact:nil
                         toContact:nil
                         timestamp:0];
}

- (instancetype)initWithPhotoUrls:(NSArray<NSString *> *)urls {
    return [self initWithPhotoUrls:urls
                       fromContact:nil
                         toContact:nil
                         timestamp:0];
}

- (instancetype)initWithPhotoUrls:(NSArray<NSString *> *)urls
                      fromContact:(Contact *)fromContact
                        toContact:(Contact *)toContact
                        timestamp:(NSTimeInterval)ts {
    self = [super initWithCellNodeClass:[GroupPhotoMessageCellNode class]
                               userInfo:nil
                            fromContact:fromContact
                              toContact:toContact
                              timestamp:ts];
    if (self) {
        _urls = urls;
    }
    return self;
}

@end
