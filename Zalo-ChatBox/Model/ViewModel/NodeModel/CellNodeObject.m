//
//  CellNodeObject.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "CellNodeObject.h"

@implementation CellNodeObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _userInfo = nil;
        _cellNodeClass = nil;
    }
    return self;
}

- (instancetype)initWithCellNodeClass:(Class)cellNodeClass userInfo:(id)userInfo {
    self = [super init];
    if (self) {
        _cellNodeClass = cellNodeClass;
        _userInfo = userInfo;
    }
    return self;
}

#pragma mark - CellNodeObject

- (ASCellNodeBlock)cellNodeBlockForObject:(id)object {
    if (!object)
        return nil;
    
    ASCellNode *(^cellNodeBlock)(void) = ^ASCellNode *() {
        if ([[object class] isSubclassOfClass:[CellNodeObject class]]) {
            id cellNode = [[self.cellNodeClass alloc] init];
            
            if ([cellNode conformsToProtocol:@protocol(CellNode)]) {
                [((id<CellNode>)cellNode) updateCellNodeWithObject:object];
            }
            return (ASCellNode *)cellNode;
        }
        return [[ASCellNode alloc] init];
    };
    
    return cellNodeBlock;
}

@end
