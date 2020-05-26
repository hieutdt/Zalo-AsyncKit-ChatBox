//
//  TableNodeModel.h
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "CellNodeObject.h"

NS_ASSUME_NONNULL_BEGIN

@class TableNodeModel;

@protocol TableNodeModelDelegate <NSObject>

@required
- (ASCellNodeBlock)tableNodeModel:(TableNodeModel *)tableNodeModel
            cellBlockForTableNode:(ASTableNode *)tableNode
                      atIndexPath:(NSIndexPath *)indexPath
                       withObject:(id)object;

@end

@interface TableNodeModel : NSObject <ASTableDataSource>

@property (nonatomic, assign) id<TableNodeModelDelegate> delegate;

- (instancetype)initWithListArray:(NSArray<id<CellNodeObject>> *)listArray
                         delegate:(id<TableNodeModelDelegate>)delegate;

- (instancetype)initWithSectionArray:(NSArray<NSArray<id<CellNodeObject>> *> *)sectionArray
                            delegate:(id<TableNodeModelDelegate>)delegate;

- (void)setListArray:(NSArray<id<CellNodeObject>> *)listArray;

- (void)setSectionArray:(NSArray<NSArray<id<CellNodeObject>> *> *)sectionArray;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForObject:(id)object;

@end

NS_ASSUME_NONNULL_END
