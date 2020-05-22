//
//  ContactTableNode.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/15/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import "ContactTableCellNode.h"
#import "ContactTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class ContactTableNode;

@protocol ContactTableNodeDelegate <NSObject>

- (void)contactTableNode:(ContactTableNode *)tableNode
     loadImageToCellNode:(ContactTableCellNode *)cellNode
             atIndexPath:(NSIndexPath *)indexPath;

- (void)contactTableNode:(ContactTableNode *)tableNode
didSelectCellAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ContactTableNode : ASDisplayNode

@property (nonatomic, strong) id<ContactTableNodeDelegate> delegate;

- (void)reloadData;

- (void)setViewModels:(NSArray<ContactTableViewModel *> *)viewModels;

@end

NS_ASSUME_NONNULL_END
