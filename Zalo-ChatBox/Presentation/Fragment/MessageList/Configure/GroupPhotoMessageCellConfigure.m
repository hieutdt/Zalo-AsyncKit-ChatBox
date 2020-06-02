//
//  GroupPhotoMessageCellConfigure.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "GroupPhotoMessageCellConfigure.h"

@interface GroupPhotoMessageCellConfigure ()

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat imageWidth;

@end

@implementation GroupPhotoMessageCellConfigure

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
        _imageWidth = [UIScreen mainScreen].bounds.size.width * 0.7/3 - 3;
    }
    return self;
}

+ (GroupPhotoMessageCellConfigure *)globalConfigure {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GroupPhotoMessageCellConfigure alloc] init];
    });
    return sharedInstance;
}

- (CGFloat)imageWidth {
    return _imageWidth;
}

- (CGFloat)verticalPadding {
    return 1;
}

- (CGFloat)verticalSpace {
    return 2;
}

- (CGFloat)horizontalPadding {
    return 10;
}

- (CGFloat)horizontalSpace {
    return 1;
}

- (NSUInteger)maxImagesInCell {
    return 3;
}

@end
