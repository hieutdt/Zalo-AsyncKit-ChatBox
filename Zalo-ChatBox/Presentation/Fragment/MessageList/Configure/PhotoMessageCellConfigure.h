//
//  PhotoMessageCellConfigure.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoMessageCellConfigure : NSObject

@property (nonatomic, readonly) CGFloat initialWidth;
@property (nonatomic, readonly) CGFloat initialHeight;
@property (nonatomic, readonly) CGFloat verticalPadding;
@property (nonatomic, readonly) CGFloat horizontalPadding;
@property (nonatomic, readonly) CGFloat horizontalSpace;
@property (nonatomic, readonly) CGFloat maxWidthOfCell;

+ (PhotoMessageCellConfigure *)globalConfigure;

@end

NS_ASSUME_NONNULL_END
