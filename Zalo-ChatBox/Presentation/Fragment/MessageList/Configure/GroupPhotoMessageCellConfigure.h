//
//  GroupPhotoMessageCellConfigure.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupPhotoMessageCellConfigure : NSObject

@property (nonatomic, readonly) CGFloat imageWidth;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) CGFloat verticalPadding;
@property (nonatomic, readonly) CGFloat verticalSpace;
@property (nonatomic, readonly) CGFloat horizontalPadding;
@property (nonatomic, readonly) CGFloat horizontalSpace;
@property (nonatomic, readonly) NSUInteger maxImagesInCell;

+ (GroupPhotoMessageCellConfigure *)globalConfigure;

@end

NS_ASSUME_NONNULL_END
