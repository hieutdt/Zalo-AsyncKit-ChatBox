//
//  TimeSectionCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeSectionCellNode : ASCellNode

- (void)setTimestamp:(NSTimeInterval)ts;

@end

NS_ASSUME_NONNULL_END
