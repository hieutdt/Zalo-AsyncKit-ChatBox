//
//  ImageCache.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ImageCache.h"

#import "ImageCache.h"
#import "AppConsts.h"

@interface ImageCache ()

@property (nonatomic, strong) NSCache<NSString *, UIImage *> *imageCache;

@end

@implementation ImageCache

- (void)customInit {
    _imageCache = [[NSCache alloc] init];
    _imageCache.countLimit = MAX_IMAGES_CACHE_SIZE;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

+ (instancetype)instance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ImageCache alloc] init];
    });
    
    return sharedInstance;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    if (!key || !image)
        return;
    
    [self.imageCache setObject:image forKey:key];
}

- (UIImage *)imageForKey:(NSString *)key {
    if (!key)
        return nil;
    
    return [self.imageCache objectForKey:key];
}

- (void)removeImageForKey:(NSString *)key {
    if (!key)
        return;
    
    [self.imageCache removeObjectForKey:key];
}

- (void)removeAllImages {
    [self.imageCache removeAllObjects];
}

#pragma mark - ASImageCacheProtocol

- (void)cachedImageWithURL:(NSURL *)URL
             callbackQueue:(dispatch_queue_t)callbackQueue
                completion:(ASImageCacherCompletion)completion {
    dispatch_async(callbackQueue, ^{
        if (completion)
            completion(nil);
    });
}


@end
