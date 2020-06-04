//
//  PhotoMessageCellConfigure.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 6/2/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PhotoMessageCellConfigure.h"

@interface PhotoMessageCellConfigure ()

@property (nonatomic, assign) CGFloat maxWidthOfCell;

@end

@implementation PhotoMessageCellConfigure

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxWidthOfCell = [UIScreen mainScreen].bounds.size.width * 0.7;
    }
    return self;
}

+ (PhotoMessageCellConfigure *)globalConfigure {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhotoMessageCellConfigure alloc] init];
    });
    return sharedInstance;
}

- (CGFloat)initialWidth {
    return 100;
}

- (CGFloat)initialHeight {
    return 100;
}

- (CGFloat)verticalPadding {
    return 15;
}

- (CGFloat)horizontalPadding {
    return 10;
}

- (CGFloat)horizontalSpace {
    return 10;
}

- (CGFloat)maxWidthOfCell {
    return _maxWidthOfCell;
}

@end
