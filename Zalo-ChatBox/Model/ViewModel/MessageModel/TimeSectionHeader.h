//
//  TimeSectionHeader.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeSectionHeader : CellNodeObject

@property (nonatomic, assign) NSTimeInterval timestamp;

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp;

@end

NS_ASSUME_NONNULL_END
