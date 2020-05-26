//
//  CellNodeObject.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CellNode <NSObject>

@required
- (void)updateCellNodeWithObject:(id)object;

@end

@class CellNodeObject;

@protocol CellNodeObject <NSObject>

@required
- (ASCellNodeBlock)cellNodeBlockForObject:(id)object;

@end

@interface CellNodeObject : NSObject <CellNodeObject>

@property (nonatomic, strong) id userInfo;
@property (nonatomic, strong) Class cellNodeClass;

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass userInfo:(_Nullable id)userInfo;

@end

NS_ASSUME_NONNULL_END
