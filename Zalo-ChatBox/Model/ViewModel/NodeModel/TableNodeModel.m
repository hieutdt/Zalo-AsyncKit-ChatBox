//
//  TableNodeModel.m
//  Zalo-ChatBox
//
//  Created by Trần Đình Tôn Hiếu on 5/26/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "TableNodeModel.h"

@interface TableNodeModel ()

@property (nonatomic, strong) NSMutableArray<NSMutableArray<id<CellNodeObject>> *> *data;

@end

@implementation TableNodeModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableArray alloc] init];
        _delegate = nil;
    }
    return self;
}

- (instancetype)initWithListArray:(NSArray<id<CellNodeObject>> *)listArray
                         delegate:(id<TableNodeModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        [self setListArray:listArray];
    }
    return self;
}

- (instancetype)initWithSectionArray:(NSArray<NSArray<id<CellNodeObject>> *> *)sectionArray
                            delegate:(id<TableNodeModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        [self setSectionArray:sectionArray];
    }
    return self;
}

#pragma mark - Public

- (void)setListArray:(NSArray<id<CellNodeObject>> *)listArray {
    _data = [[NSMutableArray alloc] init];
    [_data addObject:[NSMutableArray new]];
    for (int i = 0; i < listArray.count; i++) {
        [_data[0] addObject:listArray[i]];
    }
}

- (void)setSectionArray:(NSArray<NSArray<id<CellNodeObject>> *> *)sectionArray {
    _data = [[NSMutableArray alloc] init];
    for (int i = 0; i < sectionArray.count; i++) {
        [_data addObject:[NSMutableArray new]];
        for (int j = 0; j < sectionArray[i].count; j++) {
            [[_data lastObject] addObject:sectionArray[i][j]];
        }
    }
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath)
        return nil;
    
    if (indexPath.section >= self.data.count) {
        return nil;
    }
    
    if (indexPath.item >= self.data[indexPath.section].count) {
        return nil;
    }
    
    return self.data[indexPath.section][indexPath.item];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    if (!object)
        return nil;
    
    for (int i = 0; i < self.data.count; i++) {
        if ([self.data[i] containsObject:object]) {
            NSInteger item = [self.data[i] indexOfObject:object];
            return [NSIndexPath indexPathForItem:item inSection:i];
        }
    }
    
    return nil;
}

#pragma mark - ASTableDataSource

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return self.data.count;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    assert(section < self.data.count);
    
    return self.data[section].count;
}

- (ASCellNodeBlock)tableNode:(ASTableNode *)tableNode nodeBlockForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    
    return [self.delegate tableNodeModel:self
                   cellBlockForTableNode:tableNode
                             atIndexPath:indexPath
                              withObject:object];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


@end
