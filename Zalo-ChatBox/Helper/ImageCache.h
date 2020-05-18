//
//  ImageCache.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSObject

+ (instancetype)instance;

- (nullable UIImage *)imageForKey:(NSString *)key;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;

- (void)removeImageForKey:(NSString *)key;

- (void)removeAllImages;


@end

NS_ASSUME_NONNULL_END
