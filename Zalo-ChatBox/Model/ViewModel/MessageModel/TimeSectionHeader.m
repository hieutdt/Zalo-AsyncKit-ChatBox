//
//  TimeSectionHeader.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TimeSectionHeader.h"
#import "TimeSectionCellNode.h"

@implementation TimeSectionHeader

- (instancetype)init {
    self = [super initWithCellNodeClass:[TimeSectionCellNode class] userInfo:nil];
    if (self) {
        _timestamp = 0;
    }
    return self;
}

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp {
    self = [super initWithCellNodeClass:[TimeSectionCellNode class] userInfo:nil];
    if (self) {
        _timestamp = timestamp;
    }
    return self;
}

@end
