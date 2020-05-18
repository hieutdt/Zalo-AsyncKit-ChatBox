//
//  ContactTableCellNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ContactTableCellNode;

@protocol ContactTableCellNodeDelegate <NSObject>

- (void)didSelectCellNode:(ContactTableCellNode *)cellNode;

@end

@interface ContactTableCellNode : ASCellNode

@property (nonatomic, assign) id<ContactTableCellNodeDelegate> delegate;

- (void)setName:(NSString *)name;

- (void)setAvatar:(UIImage *)avatarImage;

- (void)setGradientColorBackground:(NSInteger)colorCode;

@end

NS_ASSUME_NONNULL_END
