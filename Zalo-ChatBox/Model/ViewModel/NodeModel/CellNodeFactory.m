//
//  CellNodeFactory.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CellNodeFactory.h"

@interface CellNodeFactory ()

@end

@implementation CellNodeFactory

#pragma mark - TableNodeModelDelegate

- (ASCellNodeBlock)tableNodeModel:(TableNodeModel *)tableNodeModel
            cellBlockForTableNode:(ASTableNode *)tableNode
                      atIndexPath:(NSIndexPath *)indexPath
                       withObject:(id)object {
    if ([object conformsToProtocol:@protocol(CellNodeObject)]) {
        return [((id<CellNodeObject>)object) cellNodeBlockForObject:object];
    } else {
        return ^ASCellNode *() {
            return [[ASCellNode alloc] init];
        };
    }
}

@end
